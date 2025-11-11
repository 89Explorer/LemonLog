//
//  DiaryEditorViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/4/25.
//

import UIKit
import Combine


final class DiaryEditorViewController: UIViewController {
    
    
    // MARK: ✅ Property
    private let diaryEditorVM: DiaryEditorViewModel
    private var cancellables = Set<AnyCancellable>()
    private var dataSource: UICollectionViewDiffableDataSource<DiaryEditorSection, DiaryEditorItem>!
    
    
    // MARK: ✅ UI
    private var diaryCollectionView: UICollectionView!

    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNavigation()
        configureDataSource()
        applySnapshot()
    }
    
    
    // MARK: ✅ Init
    init(mode: DiaryMode) {
        self.diaryEditorVM = DiaryEditorViewModel(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ DataSource Setup
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<DiaryEditorSection, DiaryEditorItem>(collectionView: diaryCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
         
            switch itemIdentifier.section {
                
                // 날짜 선택하는 섹션
            case .date:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiaryDateCell.reuseIdentifier, for: indexPath) as? DiaryDateCell else { return UICollectionViewCell() }
                cell.configure(date: Date())
                
                cell.onTapDate = { [weak self] in
                    guard let self else { return }
                    
                    let calendarVC =  CustomCalendarViewController (initializedDate: diaryEditorVM.diary.createdAt){ selectedDate in
                        print("선택된 날짜:", selectedDate.localizedString(dateStyle: .long))
                        cell.configure(date: selectedDate)
                        self.diaryEditorVM.diary.createdAt = selectedDate
                        
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
                
            case .emotion:
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmotionCell.reuseIdentifier, for: indexPath) as? EmotionCell else { return UICollectionViewCell() }
                
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
                    }
                    
                    self.present(emotionVC, animated: true)
                }
                return cell
                
            default:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
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
        
        view.addSubview(diaryCollectionView)
        
        NSLayoutConstraint.activate([
            diaryCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            diaryCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            diaryCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            diaryCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        diaryCollectionView.register(DiaryDateCell.self, forCellWithReuseIdentifier: DiaryDateCell.reuseIdentifier)
        diaryCollectionView.register(EmotionCell.self, forCellWithReuseIdentifier: EmotionCell.reuseIdentifier)
        
        diaryCollectionView.register(DiaryEditorSectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: DiaryEditorSectionHeaderView.reuseIdentifier)
        
        diaryCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
    }
    
    // MARK: ✅ createLayout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = DiaryEditorSection(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .emotion:
                return self.createBasicSection(height: 80)
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


// MARK: ✅ Extension - UIPopoverPresentationControllerDelegate
extension DiaryEditorViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
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
