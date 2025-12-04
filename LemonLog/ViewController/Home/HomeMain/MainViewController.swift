//
//  MainViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/28/25.
//


import UIKit
import Combine


final class MainViewController: UIViewController {
    
    
    // MARK: ✅ Constraint (녹색 배경 뷰 높이 설정)
    private let greenHeaderHeight: CGFloat = 260
    
    
    // MARK: ✅ ViewModel & Dependencies
    private var homeVM: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ UI
    private var mainCollectionView: UICollectionView!
    private var floatingButton: UIButton!
    private let greenHeaderView: UIView = {
        let v = UIView()
        v.backgroundColor = .softMint
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    
    // MARK: ✅ DataSource
    private var dataSource: UICollectionViewDiffableDataSource<MainViewSection, MainViewItem>!
    
    
    // MARK: ✅ Init
    init(homeVM: HomeViewModel) {
        self.homeVM = homeVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ▶️ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigation()
        
        //setupGreenHeaderView()
        setupMainCollectionView()
        
        setupFloatingButton()
        setupDataSource()
        setupBindings()
        configureButtonAction()
        
    }
    
    
    // MARK: ▶️ Setup Bindings
    private func setupBindings() {
        homeVM.$totalDiaries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] diaries in
                self?.applySnapshot(diaries: diaries)
            }
            .store(in: &cancellables)
        
        homeVM.$quote
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyQuoteSnapshot()
            }
            .store(in: &cancellables)
        
        // emotionSummary 섹션 내에 "더보기" 누르면 화면 이동
        homeVM.showWeeklySummary
            .sink { [weak self] diaries in
                let vc = HomeEmotionSummaryViewController(diariesFromWeek: diaries)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
    }
    
}


// MARK: ▶️ Extension (UI 설정)
extension MainViewController {
    
    private func setupUI() {
        view.backgroundColor = .pastelLemon
    }
    
    private func setupGreenHeaderView() {
        view.addSubview(greenHeaderView)
        
        NSLayoutConstraint.activate([
            greenHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            greenHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            greenHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            greenHeaderView.heightAnchor.constraint(equalToConstant: greenHeaderHeight)
        ])
    }
    
    
    // setup FloatingButton
    private func setupFloatingButton() {
        floatingButton = UIButton(type: .custom)
        floatingButton.layer.cornerRadius = 30
        floatingButton.clipsToBounds = true
        
        floatingButton.backgroundColor = .softMint
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let plusImage = UIImage(systemName: "plus", withConfiguration: configuration)
        floatingButton.setImage(plusImage, for: .normal)
        floatingButton.tintColor = .black
        
        floatingButton.layer.shadowColor = UIColor.black.cgColor
        floatingButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        floatingButton.layer.shadowRadius = 8
        floatingButton.layer.shadowOpacity = 0.3
        floatingButton.layer.masksToBounds = false
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60),
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    
    // MARK: Configure Button Action
    private func configureButtonAction() {
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: Action Method - Floating Button 탭 시 호출
    @objc private func floatingButtonTapped() {
        // 감정일기를 작성하는 화면으로 이동하는 로직
        let diaryEditorVC = DiaryEditorViewController(mode: .create)
        let naviToDiaryEditorVC = UINavigationController(rootViewController: diaryEditorVC)
        naviToDiaryEditorVC.modalPresentationStyle = .fullScreen
        naviToDiaryEditorVC.modalTransitionStyle = .coverVertical
        present(naviToDiaryEditorVC, animated: true)
    }
    
    
    // MARK: setup MainCollectionView
    private func setupMainCollectionView() {
        
        mainCollectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        mainCollectionView.translatesAutoresizingMaskIntoConstraints = false
        mainCollectionView.backgroundColor = .clear
        mainCollectionView.alwaysBounceVertical = false
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.delegate = self
        
        mainCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        mainCollectionView.register(QuoteCell.self, forCellWithReuseIdentifier: QuoteCell.reuseIdentifier)
        mainCollectionView.register(WeeklySummaryCell.self, forCellWithReuseIdentifier: WeeklySummaryCell.reuseIdentifier)
        mainCollectionView.register(MainDiaryListCell.self, forCellWithReuseIdentifier: MainDiaryListCell.reuseIdentifier)
        
        view.addSubview(mainCollectionView)
        
        NSLayoutConstraint.activate([
            mainCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            mainCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    // MARK: - Setup DataSource
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MainViewSection, MainViewItem>(
            collectionView: mainCollectionView
        ) { collectionView, indexPath, itemIdentifier in
            
            switch itemIdentifier {
            case .quote:
                guard case .quote(let quoteData) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: QuoteCell.reuseIdentifier,
                        for: indexPath
                      ) as? QuoteCell else { return UICollectionViewCell() }
                cell.configure(with: quoteData)
                cell.onTapRefresh = { [weak self] in
                    self?.homeVM.reloadQuote()
                }
                
                return cell
                
            case .emotionSummary:
                guard case .emotionSummary(let emotionSummaryData) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklySummaryCell.reuseIdentifier, for: indexPath) as? WeeklySummaryCell else { return UICollectionViewCell() }
                cell.configure(model: emotionSummaryData)
                
                cell.onTappedDetailText = { [weak self] summaryModel in
                    self?.homeVM.didSelectWeeklySummary(summaryModel.weekDates)
                }
                return cell
                
            case .diary(let diary):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MainDiaryListCell.reuseIdentifier,
                    for: indexPath
                ) as! MainDiaryListCell
                
                cell.configure(with: diary)
                
                cell.onTappedSetting = { [weak self] diary in
                    print("눌림")
                    self?.showSettingActionSheet(diary: diary)
                }
                return cell
                
            case .diaryPlaceholder:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainDiaryListCell.reuseIdentifier, for: indexPath) as! MainDiaryListCell
                cell.configurePlaceholder()
                return cell
            }
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let section = MainViewSection(rawValue: indexPath.section) else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath) as? SectionHeaderView else { return nil }
                header.configure(with: section.title, subtitle: section.subTitle)
                return header
            }
            return nil
        }
    }
    
    
    // MARK: - Apply Snapshot
    private func applyQuoteSnapshot() {
        var snapshot = dataSource.snapshot()
        
        // 1️⃣ quote 섹션이 없으면 추가
        if snapshot.sectionIdentifiers.contains(.quote) == false {
            snapshot.appendSections([.quote])
        }
        
        // 2️⃣ 기존 quote 아이템들 제거
        let existingQuoteItems = snapshot.itemIdentifiers(inSection: .quote)
        snapshot.deleteItems(existingQuoteItems)
        
        // 3️⃣ 새로운 quote 있으면 추가, 없으면 비워두기 (or 섹션 자체 삭제도 가능)
        if let quote = homeVM.quote {
            snapshot.appendItems([.quote(quote)], toSection: .quote)
        } else {
            // quote가 nil이면 섹션만 남기고 비워두거나, 아예 섹션 삭제도 가능
            // snapshot.deleteSections([.quote])
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func applySnapshot(diaries: [EmotionDiaryModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<MainViewSection, MainViewItem>()
        
        snapshot.appendSections(MainViewSection.allCases)
        
        if let quote = homeVM.quote {
            snapshot.appendItems([.quote(quote)], toSection: .quote)
        }
        
        if diaries.isEmpty {
            snapshot.appendItems([.diaryPlaceholder],toSection: .diary)
        } else {
            let items = diaries.map { MainViewItem.diary($0) }
            snapshot.appendItems(items, toSection: .diary)
        }
        
        let summaryModel = homeVM.makeWeeklyEmotionSummaryModel(for: Date(), baseMonth: Date())
        snapshot.appendItems([.emotionSummary(summaryModel)], toSection: .emotionSummary)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    
    // MARK: createLayout()
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            guard let section = MainViewSection(rawValue: sectionIndex) else { return nil }
            
            switch section {
            case .quote:
                return self.quoteSectionLayout()
            case .emotionSummary:
                return self.emotionSummaryLayout()
            case .diary:
                return self.diarySectionLayout()
            }
        }
    }
    
    private func quoteSectionLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(140)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 20, bottom: 20, trailing: 20
        )
        
        return section
    }
    
    private func emotionSummaryLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: itemSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    
    // MARK: diarySectionLayout()
    private func diarySectionLayout() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(320)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // 그룹: 좌우 inset 적용된 "카드 하나"를 화면 가운데에 두기 위해 absolute width 사용
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.93),  // 카드 폭
            heightDimension: .estimated(320)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)

        // 🔥 가운데 정렬 핵심
        section.contentInsets = .init(top: 0, leading: 20, bottom: 32, trailing: 20)

        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 8

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        return section
    }

}



// MARK: - Extension (네비게이션바 설정)
extension MainViewController {
    
    private func setupNavigation() {
        
        //makeNavigationTransparent()
        
        // MARK: ✅ Navigation - 로고 이미지 + 앱 이름
        // 원본 이미지 -> 리사이즈 -> 원본 렌더링
        let logo = UIImage(named: "lemon")?
            .resized(to: CGSize(width: 32, height: 32))
            .withRenderingMode(.alwaysOriginal)
        
        // 로고 이미지뷰
        let imageView = UIImageView(image: logo)
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 32),
            imageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        // 타이틀 라벨
        let titleLabel = UILabel()
        titleLabel.text = "레몬로그"
        titleLabel.font = UIFont(name: "DungGeunMo", size: 20)
        //titleLabel.font = .systemFont(ofSize: 20, weight: .black)
        titleLabel.textColor = .black
        
        // 스택으로 묶기
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // 컨테이너 뷰 (탭 영역 넓히기 + 오토레이아웃 고정)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 32))
        container.addSubview(stackView)
        container.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: container)
        
        // 탭 액션 연결
        let logoTap = UITapGestureRecognizer(target: self, action: #selector(didTapLogo))
        container.addGestureRecognizer(logoTap)
        
        
        // MARK: ✅ Navigation Button - (Search, List, Alarm)
        // 아이콘 이름 배열
        let buttonsInfo: [(systemName: String, action: Selector)] = [
            ("magnifyingglass", #selector(didTapSearch)),
            ("bell", #selector(didTapBell))
        ]
        
        // 버튼 생성
        let rightButtons: [UIBarButtonItem] = buttonsInfo.map { info in
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: info.systemName), for: .normal)
            button.tintColor = .black
            button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
            
            // 터치 인식 정확하게
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            button.configuration = configuration
            
            button.addTarget(self, action: info.action, for: .touchUpInside)
            return UIBarButtonItem(customView: button)
        }
        
        // 버튼 배열 적용 (bell → list → search 순서)
        navigationItem.rightBarButtonItems = rightButtons.reversed()
        
    }
    
    private func makeNavigationTransparent() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.5)
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        //navigationController?.navigationBar.isTranslucent = true
    }
    
    
    // MARK: ✅ @objc 액션 메서드
    
    // 로고가 눌리면 동작하는 액션
    @objc private func didTapLogo() {
        // TODO: 원하는 액션
        print("🍋 레몬로그 tapped")
    }
    
    // 검색 버튼이 눌리면 동작하는 액션
    @objc private func didTapSearch() {
        print("🔍 검색 버튼 탭됨")
        // TODO: 검색 화면 이동
    }
    
    // 알람 버튼이 눌리면 동작하는 액션
    @objc private func didTapBell() {
        print("🔔 알림 버튼 탭됨")
        // TODO: 알림 화면 이동
    }
    
}


// MARK: Extension (settingButton이 눌리면, 삭제 or 수정 or 취소)
extension MainViewController {
    
    func showSettingActionSheet(diary: EmotionDiaryModel) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 수정
        let editAction = UIAlertAction(
            title: NSLocalizedString("edit_action", comment: "Edit diary"),
            style: .default
        ) { [weak self] _ in
            self?.handleEdit(diary: diary)
            print("수정 눌림")
        }
        alert.addAction(editAction)
        
        
        // 삭제
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete_action", comment: "Delete diary"),
            style: .destructive
        ) { [weak self] _ in
            self?.showDeleteConfirmation(diary: diary)
        }
        alert.addAction(deleteAction)
        
        
        // 취소
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel_action", comment: "Cancel action"),
            style: .cancel,
            handler: nil
        )
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    
    // 삭제 버튼을 눌렀을 때 확인창 여는 함수
    private func showDeleteConfirmation(diary: EmotionDiaryModel) {
        
        let title = NSLocalizedString("delete_confirm_title", comment: "Delete diary confirmation")
        
        let message = NSLocalizedString("delete_confirm_message", comment: "Delete diary confirmation")
        
        let confirmAlert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let confirmDelete = UIAlertAction(
            title: NSLocalizedString("delete_action", comment: "Confirm delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.handleDelete(diary: diary)
        }
        confirmAlert.addAction(confirmDelete)
        
        let cancel = UIAlertAction(
            title: NSLocalizedString("cancel_action", comment: "Cancel"),
            style: .cancel,
            handler: nil
        )
        confirmAlert.addAction(cancel)
        
        present(confirmAlert, animated: true)
    }
    
    private func handleDelete(diary: EmotionDiaryModel) {
        // 여기서 CoreData 삭제 또는 ViewModel 호출 등 처리
        print("삭제 실행")
        DiaryStore.shared.delete(id: diary.id.uuidString)
        navigationController?.dismiss(animated: true)
        ToastManager.show(.deleted, position: .center)
    }
    
    private func handleEdit(diary: EmotionDiaryModel) {
        let selectedDiary = diary
        let editVC = DiaryEditorViewController(mode: .edit(selectedDiary))
        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        self.navigationController?.present(nav, animated:true)
    }
}


// MARK: ✅ Extension (Scroll 애니메이션 - GreenHeaderView 위로 사라짐)
extension MainViewController: UIScrollViewDelegate, UICollectionViewDelegate {
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        let defaultOffset = view.safeAreaInsets.top
//        let offset = scrollView.contentOffset.y + defaultOffset
//        
//        navigationController?.navigationBar.transform = .init(translationX: 0, y: -offset)
//    }
}


// MARK: - Enum (MainCollectionView에 사용될, 섹션과 아이템)
extension MainViewController {
    
    
    // Enum Section
    enum MainViewSection: Int, CaseIterable {
        case quote
        case emotionSummary
        case diary
        
        var title: String {
            switch self {
            case .emotionSummary:
                return NSLocalizedString("home_section_emotion_summary_title",
                                         comment: "Label for weekly emotion summary section")
            case .diary:
                return NSLocalizedString("home_section_random_entries_title", comment: "")
            default:
                return ""
            }
        }
        
        var subTitle: String {
            switch self {
            case .emotionSummary: return NSLocalizedString("home_section_emotion_summary_subtitle", comment: "Label for weekly emotion summary section subTitle")
            case .diary:
               return  NSLocalizedString("home_section_random_entireis_subtitle", comment: "")
            default:
                return ""
            }
        }
    }
    
    // Enum Item
    enum MainViewItem: Hashable {
        case quote(HappinessQuote)
        case emotionSummary(WeeklyEmotionSummaryModel)
        case diary(EmotionDiaryModel)
        case diaryPlaceholder  // diary에 데이터가 없을 경우 -> 안내 메시지를 보여주기 위함
    }
}


extension EmotionDiaryModel {
    static var emptyPlaceholder: EmotionDiaryModel {
        EmotionDiaryModel(
            id: UUID(),
            emotion: "",
            content: "",
            createdAt: Date(),
            images: []
        )
    }
}
