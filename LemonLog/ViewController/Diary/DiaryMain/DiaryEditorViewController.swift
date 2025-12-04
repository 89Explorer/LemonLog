//
//  DiaryEditorViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/4/25.
//

import UIKit
import Combine
import UniformTypeIdentifiers


final class DiaryEditorViewController: UIViewController {
    
    
    // MARK: ✅ Property
    private let diaryEditorVM: DiaryEditorViewModel
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<DiaryEditorSection, DiaryEditorItem>!
    
    private var keyboardHeight: CGFloat = 0
    private var activeTextViewFrame: CGRect?
    
    private var currentPhotoCell: DiaryPhotoGalleryCell?
    
    // DiaryContentCell 클래스에서 사용할 목적 - 값이 변경될 때 저장 목적
    private var currentContentSections = ContentSections(
        situation: "",
        thought: "",
        reeval: "",
        action: ""
    )
    
    
    // MARK: ✅ UI
    private var diaryCollectionView: UICollectionView!
    
    
    // MARK: ✅ Init
    init(mode: DiaryMode) {
        self.diaryEditorVM = DiaryEditorViewModel(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavigation()
        configureDataSource()
        applySnapshot()
        registerForKeyboardNotifications()

        diaryCollectionView.alwaysBounceVertical = true
        
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openEmotionSelectorIfNeeded()
    }
    
    
    // MARK: ✅ openEmotionSelectorIfNeeded -> 창이 열리면 바로 감정을 선택할 수 있도록 해주는 함수
    private func openEmotionSelectorIfNeeded() {
        
        // edit 모드라면 자동 오픈
        if case .edit = diaryEditorVM.mode {
            return
        }
        
        // 이미 감정을 선택했다면 자동으로 열리지 않게
        if !diaryEditorVM.diary.emotion.isEmpty { return }

        let indexPath = IndexPath(item: 0, section: DiaryEditorSection.emotion.rawValue)
        
        guard let cell = diaryCollectionView.cellForItem(at: indexPath) as? EmotionCell else {
            // 셀이 아직 로딩되지 않았으면 약간 기다렸다가 실행
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.openEmotionSelectorIfNeeded()
            }
            return
        }
        
        cell.triggerOpenEmotionPicker()
    }

    
    // MARK: ✅ Binding
    private func bindViewModel() {
        
        // 유효성 검사 구독
        diaryEditorVM.$validationResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self, let result else { return }
                self.applyValidationErrors(result.errors)
            }
            .store(in: &cancellables)
        
        // 유효성 검사 결과 구독 -> 참일 경우 창 닫힘
        diaryEditorVM.$saveCompleted
            .receive(on: RunLoop.main)
            .sink { [weak self] completed in
                guard let self, completed else { return }
                self.navigationController?.dismiss(animated: true)
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: ✅ DataSource Setup
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DiaryEditorSection, DiaryEditorItem>(collectionView: diaryCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
         
            switch itemIdentifier.section {
                
            // -------------------------------------- 날짜 섹션
            case .date:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDateCell.reuseIdentifier, for: indexPath) as? DiaryDateCell else { return UICollectionViewCell() }
                
                let date = self.diaryEditorVM.diary.createdAt
                cell.configure(date: date)
                
                cell.onTapDate = { [weak self] in
                    guard let self else { return }
                    
                    self.showDim()
                    let calendarVC =  CustomCalendarViewController (initializedDate: diaryEditorVM.diary.createdAt){ selectedDate in
                        //print("선택된 날짜:", selectedDate.localizedString(dateStyle: .long))
                        cell.configure(date: selectedDate)
                        self.diaryEditorVM.diary.createdAt = selectedDate
                        self.hideDim()
                        
                    }
                    calendarVC.modalPresentationStyle = .popover
                    calendarVC.preferredContentSize = CGSize(width: 320, height: 280)
                    
                    if let popover = calendarVC.popoverPresentationController {
                        popover.sourceView = self.view
                        popover.sourceRect = CGRect(
                            x: self.view.bounds.midX,
                            y: self.view.bounds.midY,
                            width: 0,
                            height: 0
                        )
                        popover.delegate = self
                        popover.permittedArrowDirections = []  // 화살표 제거
                    }
                    self.present(calendarVC, animated: true)
                }
                return cell
                
            // -------------------------------------- 감정 섹션
            case .emotion:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionCell.reuseIdentifier, for: indexPath) as? EmotionCell else { return UICollectionViewCell() }
                
                // 기존 emotion 표시
                if let emotion = self.diaryEditorVM.diary.emotionCategory {
                    cell.configure(with: emotion)
                }
                
                cell.onAddButtonTapped = {
                    let emotionVC = EmotionViewController()
                    
                    if let sheet = emotionVC.sheetPresentationController {
                        sheet.detents = [.large()]
                        sheet.prefersGrabberVisible = true
                    }
                    
                    emotionVC.onEmotionSelected = { [weak self] emotion in
                        guard let self = self else { return }
                        self.diaryEditorVM.diary.emotion = emotion.rawValue
                        cell.configure(with: emotion)
                        
                        //cell.clearError()  // 유효성 검사 실패시 나오는 문구를 감정을 선택하면 숨김
                    }
                    
                    self.present(emotionVC, animated: true)
                }
                return cell
                
            // ------------------------------ 내용 섹션
            case .content:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryContentCell.reuseIdentifier, for: indexPath) as? DiaryContentCell else {
                    return UICollectionViewCell()
                }
                
                let content = self.diaryEditorVM.contentSections
                cell.configure(with: content)
                
                cell.onFocusChanged = { [weak self] view in
                    guard let self else { return }
                    // ✅ 포커스된 텍스트뷰의 전역 좌표를 저장
                    self.activeTextViewFrame = view.convert(view.bounds, to: self.diaryCollectionView)
                }
                
                cell.onContentChanged = { [weak self] sections in
                    guard let self else { return }
                    self.diaryEditorVM.contentSections = sections
                    
                }
                
                return cell
                
            // -------------------------------- 사진 섹션
            case .photogallery:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryPhotoGalleryCell.reuseIdentifier, for: indexPath) as? DiaryPhotoGalleryCell else {
                    return UICollectionViewCell()
                }
                
                if let images = self.diaryEditorVM.diary.images {
                    cell.updateImages(images)
                }
                
                // 기존의 Cell 에서 parentViewController()를 통해 호출하는 방식에서 클로저로 변환
                cell.onAddPhotoTapped = { [weak self] in
                    self?.showPhotoSourceActionSheet(from: cell)
                }
                
                // 사진첩에서 선택
                cell.onRequestPhotoLibrary = { [weak self] in
                    guard let self else { return }
                    
                    MediaPermissionManager.shared.checkAndRequestIfNeeded(.album) { granted in
                        if granted {
                            self.openPhotoPicker()
                        } else {
                            self.showPermissionAlert(type: .album)
                        }
                    }
                }
                
                // 카메라 촬영
                cell.onRequestCamera = { [weak self] in
                    guard let self else { return }
                    
                    MediaPermissionManager.shared.checkAndRequestIfNeeded(.camera) { granted in
                        if granted {
                            self.openCamera()
                        } else {
                            self.showPermissionAlert(type: .camera)
                        }
                    }
                }
                
                // 파일 선택
                cell.onRequestDocument = { [weak self] in
                    self?.presentDocumentPicker()
                }
                
                // 이미지 전체보기
                cell.onPreviewRequested = { [weak self] images, startIndex in
                    guard let self else { return }
                    let previewVC = PhotoPreviewViewController(images: images, startIndex: startIndex)
                    self.present(previewVC, animated: true)
                }
                
                // 이미지 변경될 때마다 ViewModel에 반영
                cell.onImagesUpdated = { [weak self] images in
                    self?.diaryEditorVM.diary.images = images
                }
             
                return cell
             
            // ------------------------------- 저장 버튼
            case .saveButton:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaveButtonCell.reuseIdentifier, for: indexPath) as? SaveButtonCell else { return UICollectionViewCell() }
                
                cell.onTapSave = { [weak self] in
                    guard let self else { return }
                    
                    let diaryContent = self.diaryEditorVM.contentSections
                    
                    self.diaryEditorVM.attemptSaveDiary(
                        situation: diaryContent.situation,
                        thought: diaryContent.thought,
                        reeval: diaryContent.reeval,
                        action: diaryContent.action
                    )
                    
                    switch self.diaryEditorVM.mode {
                    case .create:
                        ToastManager.show(.saved, position: .center)
                    default:
                        ToastManager.show(.updated, position: .center)
                    }
                    
                }
                
                return cell
                
            }
        })
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = DiaryEditorSection(rawValue: indexPath.section) else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: DiaryEditorSectionHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? DiaryEditorSectionHeaderView else {
                    return nil
                }
                
                header.configure(with: section.title)
                return header
            }
            return nil
        }
    }
    
    
    // MARK: ✅ Snapshot Setup
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<DiaryEditorSection, DiaryEditorItem>()
        snapshot.appendSections(DiaryEditorSection.allCases)
        
        let diary = diaryEditorVM.diary
        
        snapshot.appendItems([DiaryEditorItem(section: .date, content: diary.createdAt.formatted())], toSection: .date)
        snapshot.appendItems([DiaryEditorItem(section: .emotion, content: diary.emotionCategory?.rawValue)], toSection: .emotion)
        snapshot.appendItems([DiaryEditorItem(section: .content, content: diary.content)], toSection: .content)
        snapshot.appendItems([DiaryEditorItem(section: .photogallery, content: nil)], toSection: .photogallery)
        snapshot.appendItems([DiaryEditorItem(section: .saveButton, content: nil)], toSection: .saveButton)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .sageGreen
        
        diaryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        diaryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        diaryCollectionView.backgroundColor = .clear
        diaryCollectionView.keyboardDismissMode = .interactive
        
        view.addSubview(diaryCollectionView)
        
        NSLayoutConstraint.activate([
            diaryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            diaryCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            diaryCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            diaryCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // diaryCollectionView 에 셀 등록
        diaryCollectionView.register(DiaryDateCell.self, forCellWithReuseIdentifier: DiaryDateCell.reuseIdentifier)
        diaryCollectionView.register(EmotionCell.self, forCellWithReuseIdentifier: EmotionCell.reuseIdentifier)
        diaryCollectionView.register(DiaryContentCell.self, forCellWithReuseIdentifier: DiaryContentCell.reuseIdentifier)
        diaryCollectionView.register(DiaryPhotoGalleryCell.self, forCellWithReuseIdentifier: DiaryPhotoGalleryCell.reuseIdentifier)
        diaryCollectionView.register(SaveButtonCell.self, forCellWithReuseIdentifier: SaveButtonCell.reuseIdentifier)
        
        diaryCollectionView.register(DiaryEditorSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryEditorSectionHeaderView.reuseIdentifier)
        
    }
    
    
    // MARK: ✅ createLayout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = DiaryEditorSection(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .emotion:
                return self.createBasicSection(height: 100)
            case .content:
                return self.createContentSection()
            case .photogallery:
                return self.createBasicSection(height: 140)
            case .saveButton:
                return self.createSaveButtonSection(height: 48)
            default: return self.createBasicSection(height: 52)
            }
        }
    }
    
    
    // MARK: ✅ creatBasicSection
    private func createBasicSection(height: CGFloat, headerSpacing: CGFloat = 20, footerSpacing: CGFloat = 16) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: headerSpacing, leading: 16, bottom: footerSpacing, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    
    // MARK: ✅ createContentSection - contentSection
    private func createContentSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(40))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    
    // MARK: ✅ createSaveButtonSection() - 저장버튼 섹션 레이아웃
    private func createSaveButtonSection(height: CGFloat, headerSpacing: CGFloat = 20, footerSpacing: CGFloat = 16) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: headerSpacing, leading: 16, bottom: footerSpacing, trailing: 16)
        return section
    }
    
    
    // MARK: ✅ registerForKeyboardNotifications - 키보드 감지
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: ✅ handleKeyboardShow - 키보드 보이기
    @objc private func handleKeyboardShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        keyboardHeight = frame.height
        
        diaryCollectionView.contentInset.bottom = keyboardHeight + 20
        diaryCollectionView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        
        guard let textViewFrame = activeTextViewFrame else { return }

        // 화면에서 키보드를 제외한 '남은 영역'
        let visibleHeight = view.bounds.height - keyboardHeight

        // 텍스트뷰의 중앙 위치
        let textViewCenterY = textViewFrame.midY

        // 텍스트뷰가 화면의 절반 아래로 내려가 있으면 키보드에 가림 → 올려준다
        if textViewCenterY > visibleHeight * 0.6 {

            // 텍스트뷰를 화면 중앙 slightly above 로 위치시키는 offset
            let targetY = textViewFrame.minY - (visibleHeight * 0.475)

            let rect = CGRect(
                x: 0,
                y: targetY,
                width: view.bounds.width,
                height: textViewFrame.height + keyboardHeight
            )
            
            diaryCollectionView.scrollRectToVisible(rect, animated: true)
        }
    }
    
    
    // MARK: ✅ handleKeyboardHide - 키보드 숨기기
    @objc private func handleKeyboardHide(_ notification: Notification) {
        diaryCollectionView.contentInset.bottom = 0
        diaryCollectionView.verticalScrollIndicatorInsets.bottom = 0
        activeTextViewFrame = nil
    }
    
}


// MARK: ✅ NavigationController - 네비게이션 설정
extension DiaryEditorViewController {
    
    private func configureNavigation() {
        navigationItem.hidesBackButton = true
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
    
        let iconImage = UIImage(systemName: "xmark", withConfiguration: iconConfig)
        
        let backButton = UIButton(type: .system)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        backButton.setImage(iconImage, for: .normal)

        let barButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButtonItem
        
        navigationItem.title = diaryEditorVM.navigationTitle
    
    }
    
    @objc private func didTapDismiss() {
        navigationController?.dismiss(animated: true)
    }
}


// MARK: ✅ Extension - UIPopoverPresentationControllerDelegate -> 커스텀 캘린더 관련 내용
extension DiaryEditorViewController: UIPopoverPresentationControllerDelegate {
    
    // 사용자가 커스텀 캘린더뷰의 팝오버 바깥을 눌러서 닫았을 때 호출됨
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.hideDim()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}


// MARK: ✅ Extension - showPhotoSourceActionSheet() -> 사진첩
extension DiaryEditorViewController {
    
    func showPhotoSourceActionSheet(from cell: DiaryPhotoGalleryCell) {
        
        self.currentPhotoCell = cell
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 사진 보관함
        let galleryAction = UIAlertAction(
            title: NSLocalizedString("photo.sheet.gallery", comment: ""),
            style: .default,
            handler: { _ in
            cell.onRequestPhotoLibrary?()
        })
        alert.addAction(galleryAction)
        
        // 사진 찍기
        let cameraAction = UIAlertAction(
            title: NSLocalizedString("photo.sheet.camera", comment: ""),
            style: .default,
            handler: { _ in
            cell.onRequestCamera?()
        })
        alert.addAction(cameraAction)
        
        // 파일 선택
        let fileAction = UIAlertAction(
            title: NSLocalizedString("photo.sheet.file", comment: ""),
            style: .default,
            handler: { _ in
            cell.onRequestDocument?()
        })
        alert.addAction(fileAction)
        
        // 취소
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("photo.sheet.cancel", comment: ""),
            style: .cancel
        ))
        
        present(alert, animated: true)
        
    }
}


// MARK: ✅ Extension - UIDocumentPickerDelegate
extension DiaryEditorViewController: UIDocumentPickerDelegate {
    
    func presentDocumentPicker() {
        
        // 파일 보관함에서 "이미지"만 보이게 필터링
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [UTType.image],
            asCopy: true
        )
        
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        
        guard let url = urls.first,
              let cell = currentPhotoCell else { return }
        
        let coordinated = url.startAccessingSecurityScopedResource()
        
        defer {
            if coordinated {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            let data = try Data(contentsOf: url)
            if let image = UIImage(data: data)?.resized() {
                cell.appendImage(image)
            }
        } catch {
            LogManager.print(.error, "파일 로드 실패 \(error.localizedDescription)")
        }
    }
    
}


// MARK: ✅ Extension - UIImagePickerControllerDelegate,UINavigationControllerDelegate -> 사진 선택
extension DiaryEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func openCamera() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    // 선택 완료
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage,
           let cell = currentPhotoCell {
            cell.appendImage(image)
        }

        picker.dismiss(animated: true)
    }
    
}


// MARK: ✅ Extension - showPermissionAlert() -> 안내 메시지
extension DiaryEditorViewController {
    
    func showPermissionAlert(type: MediaPermissionType) {
        
        let titleKey = (type == .camera)
            ? "photo.permission.camera.title"
            : "photo.permission.album.title"
        
        let title = NSLocalizedString(titleKey, comment: "")
        let message = NSLocalizedString("photo.permission.message", comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let setting = UIAlertAction(
            title: NSLocalizedString("photo.permission.gotoSetting", comment: ""),
            style: .default
        ) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        
        let confirm = UIAlertAction(
            title: NSLocalizedString("photo.permission.confirm", comment: ""),
            style: .cancel
        )
        
        alert.addAction(setting)
        alert.addAction(confirm)
        
        present(alert, animated: true)
    }
    
}


// MARK: ✅ Extension - 유효성 검사 목적
extension DiaryEditorViewController {
    
    // Validation UI 적용
    private func applyValidationErrors(_ errors: [DiaryValidationError]) {
        
            
        guard !errors.isEmpty else {
            //clearAllValidationUI()
            return
        }
        
        for error in errors {
            switch error.field {
                
            case .emotion:
                showEmotionError(message: error.message)
                
            case .situation, .thought, .reeval, .action:
                showContentError(field: error.field, message: error.message)
                
            }
        }
        
        // 첫 오류 위치로 스크롤
        if let first = errors.first {
            scrollToField(first.field)
        }
    }
    
    // Validation UI 제거
    private func clearAllValidationUI() {
        
        // Emotion Cell
        if let cell = diaryCollectionView.cellForItem(
            at: IndexPath(item: 0, section: DiaryEditorSection.emotion.rawValue)
        ) as? EmotionCell {
            cell.clearError()
        }
        
        // Content Cell
        if let cell = diaryCollectionView.cellForItem(
            at: IndexPath(item: 0, section: DiaryEditorSection.content.rawValue)
        ) as? DiaryContentCell {
            cell.clearAllErrors()
        }
    }
    
    // show Error - Emotion 셀
//    private func showEmotionError(message: String) {
//        reloadEmotionSection()
//
//        DispatchQueue.main.async {
//            let idx = IndexPath(item: 0, section: DiaryEditorSection.emotion.rawValue)
//            if let cell = self.diaryCollectionView.cellForItem(at: idx) as? EmotionCell {
//                cell.showError(message: message)
//            }
//        }
//    }
    
//    private func reloadEmotionSection() {
//        var snapshot = dataSource.snapshot()
//        let items = snapshot.itemIdentifiers(inSection: .emotion)
//        snapshot.reloadItems(items)
//        dataSource.apply(snapshot, animatingDifferences: false)
//    }

    // show Error - Emotion 셀
    private func showEmotionError(message: String) {
        let indexPath = IndexPath(item: 0, section: DiaryEditorSection.emotion.rawValue)
        guard let cell = diaryCollectionView.cellForItem(at: indexPath) as? EmotionCell else { return }
        cell.showError(message: message)
    }
    
    // show Error - Content 셀
    private func showContentError(field: DiaryField, message: String) {
        let indexPath = IndexPath(item: 0, section: DiaryEditorSection.content.rawValue)
        guard let cell = diaryCollectionView.cellForItem(at: indexPath) as? DiaryContentCell else { return }
        cell.showError(for: field, message: message)
    }
    
    // 에러가 발생한 곳으로 스클
    private func scrollToField(_ field: DiaryField) {
        switch field {
            
        case .emotion:
            scrollTo(section: .emotion)
            
        case .situation, .thought, .reeval, .action:
            scrollTo(section: .content)
        }
    }
        
    private func scrollTo(section: DiaryEditorSection) {
        let indexPath = IndexPath(item: 0, section: section.rawValue)
        diaryCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
}


// MARK: ✅ Extension - DiaryCollectionView 섹션
extension DiaryEditorViewController {
    
    // diary 화면의 섹션 구분
    enum DiaryEditorSection: Int, CaseIterable {
        case date
        case emotion
        case content
        case photogallery
        case saveButton
        
        var title: String {
            switch self {
            case .date:
                return NSLocalizedString("diary_editor_section_date_title", comment: "Title for the date section in diary editor")
            case .emotion:
                return NSLocalizedString("diary_editor_section_emotion_title", comment: "Title for the emotion selection section in diary editor")
            case .content:
                return NSLocalizedString("diary_editor_section_content_title", comment: "Title for the content writing section in diary editor")
            case .photogallery:
                return NSLocalizedString("diary_editor_section_photogallery_title", comment: "Title for the photo gallery section in diary editor")
            case .saveButton:
                return NSLocalizedString("diary_editor_section_save_button_title", comment: "Title for the save button section in diary editor")
            }
        }
    }
    
    // diary 화면의 섹션에 대한 아이템 정보
    struct DiaryEditorItem: Hashable {
        let id = UUID()
        let section: DiaryEditorViewController.DiaryEditorSection
        let content: String?
        let placeholder: String?
        
        init(section: DiaryEditorViewController.DiaryEditorSection,
             content: String? = nil,
             placeholder: String? = nil) {
            self.section = section
            self.content = content
            self.placeholder = placeholder
        }
    }
}
