//
//  HomeViewController.swift
//  LemonLog
//
//  Created by 권정근 on 10/12/25.
//

import UIKit
import Combine


@MainActor
final class HomeViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
//#if DEBUG
//    private var homeVM = HomeViewModel.mock()
//#else
//    private var homeVM = HomeViewModel()
//#endif

    private var homeVM = HomeViewModel()
    
    // MARK: ✅ DiffableDataSource
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
    
    // MARK: ✅ Dependencies
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ UI
    private var homeCollectionView: UICollectionView!
    private var floatingButton: UIButton!
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigation()
        configureUI()
        configureButtonAction()
        configureDataSource()
        bindViewModel()
        applySnapshot()
    }
    
    
    // MARK: ✅ DataSource Setup
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: homeCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            // 어떤 섹션인지 확인
            guard let section = HomeSection(rawValue: indexPath.section) else {
                return UICollectionViewCell()
            }
            
            switch section {
            case .quote:
                guard case .quote(let quoteData) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuoteCell.reuseIdentifier, for: indexPath) as? QuoteCell else { return UICollectionViewCell() }
                cell.configure(with: quoteData)
                
                cell.onTapRefresh = { [weak self] in
                    self?.homeVM.reloadQuote()
                }
                return cell
    
            case .emotionSummary:
                guard case .emotionSummary(let emotionSummary) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklySummaryCell.reuseIdentifier, for: indexPath) as? WeeklySummaryCell else { return UICollectionViewCell() }
                cell.configure(weekText: emotionSummary.weekDescription, emotions: emotionSummary.mostFrequentByWeekday, top3: emotionSummary.top3Emotion)
                return cell
                
            case .recentEntries:
                guard case .diary(let recentDiary) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiarySummaryCell.reuseIdentifier, for: indexPath) as? DiarySummaryCell else { return UICollectionViewCell() }
                cell.configure(with: recentDiary)
                return cell
                
            case .photoGallery:
                guard case .photo(let image, let diaryID) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(
                          withReuseIdentifier: PhotoGalleryCell.reuseIdentifier,
                          for: indexPath
                      ) as? PhotoGalleryCell else {
                    return UICollectionViewCell()
                }
                
                cell.configure(with: image, diaryID: diaryID)
                return cell
            }

        })
        
        // SupplementaryViewProvider: Header + Footer 둘 다 처리
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
                guard let section = HomeSection(rawValue: indexPath.section) else { return nil }
                
                // 🔹 Header 처리
                if kind == UICollectionView.elementKindSectionHeader {
                    guard let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind,
                        withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                        for: indexPath
                    ) as? SectionHeaderView else {
                        return nil
                    }
                    header.configure(with: section.title, subtitle: section.subtitle)
                    return header
                }
                
                return nil
            }
    }
    
    
    // MARK: ✅ Snapshot Setup
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        snapshot.appendSections(HomeSection.allCases)
        
        // 1️⃣ 명언 섹션
        if let quote = homeVM.quote {
            snapshot.appendItems([.quote(quote)], toSection: .quote)
        }
        
        // 2️⃣ 감정 요약
        let summaryModel = homeVM.makeWeeklyEmotionSummaryModel()
        snapshot.appendItems([.emotionSummary(summaryModel)], toSection: .emotionSummary)
        
        // 3️⃣ 최근 일기
        snapshot.appendItems(homeVM.recentDiaries.map { .diary($0) }, toSection: .recentEntries)
        
        // 4️⃣ 사진 일기
        snapshot.appendItems(
            homeVM.diaryImages.map { .photo(image: $0.image, diaryID: $0.diaryID) },
            toSection: .photoGallery
        )
        
        // 5️⃣ 데이터 적용 (UI 업데이트)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    
    // MARK: ✅ Bind
    private func bindViewModel() {
        homeVM.$quote
            .sink { [weak self] _ in self?.applySnapshot() }
            .store(in: &cancellables)
        
        homeVM.$recentDiaries
            .sink { [weak self] _ in self?.applySnapshot() }
            .store(in: &cancellables)
        
        homeVM.$emotionSummary
            .sink { [weak self] _ in self?.applySnapshot() }
            .store(in: &cancellables)
        
        homeVM.$diaryImages
            .sink { [weak self] _ in self?.applySnapshot() }
            .store(in: &cancellables)
    }

    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .pastelLemon
        
        homeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        homeCollectionView.showsVerticalScrollIndicator = false
        homeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        homeCollectionView.backgroundColor = .clear
        
        floatingButton = UIButton(type: .custom)
        floatingButton.layer.cornerRadius = 30
        floatingButton.clipsToBounds = true
        
        floatingButton.backgroundColor = .sageGreen
        
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
        
        view.addSubview(homeCollectionView)
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            homeCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            homeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            floatingButton.widthAnchor.constraint(equalToConstant: 60),
            floatingButton.heightAnchor.constraint(equalToConstant: 60),
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        homeCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        homeCollectionView.register(QuoteCell.self, forCellWithReuseIdentifier: QuoteCell.reuseIdentifier)
        homeCollectionView.register(WeeklySummaryCell.self, forCellWithReuseIdentifier: WeeklySummaryCell.reuseIdentifier)
        homeCollectionView.register(DiarySummaryCell.self, forCellWithReuseIdentifier: DiarySummaryCell.reuseIdentifier)
        homeCollectionView.register(PhotoGalleryCell.self, forCellWithReuseIdentifier: PhotoGalleryCell.reuseIdentifier)
        homeCollectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.reuseIdentifier)
    }
    
    
    // MARK: ✅ CompositionalLayout 구성
    private func createLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = HomeSection(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .quote:
                return self.createQuoteSectionLayout()
            case .emotionSummary:
                return self.createEmotionSummarySectionLayout()
            case .recentEntries:
                return self.createRecentEntriesSectionLayout()
            case .photoGallery:
                return self.createPhotoGallerySectionLayout()
            }
        }
    }
    
    
    // MARK: ✅ createQuoteSectionLayout - 명언 섹션 구성
    private func createQuoteSectionLayout() -> NSCollectionLayoutSection {
        
        // 아이템 정의 
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(140))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(140))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        // 섹션 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    
    // MARK: ✅ createEmotionSummarySectionLayout - 주간 감정 요약 섹션 구성
    private func createEmotionSummarySectionLayout() -> NSCollectionLayoutSection {
       
        // 아이템 정의
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        //item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        // 섹션 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        return section
    }

    
    // MARK: ✅ createRecentEntriesSectionLayout - 최근 일기 섹션 구성
    private func createRecentEntriesSectionLayout() -> NSCollectionLayoutSection {
        // 아이템 정의
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = .init(top: 0, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(140))
       
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 8, trailing: 16)
        section.orthogonalScrollingBehavior = .continuous
        
        // 섹션 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }

    
    // MARK: ✅ createPhotoGallerySectionLayout - 포토 갤러리 섹션 구성
    private func createPhotoGallerySectionLayout() -> NSCollectionLayoutSection {
        // 아이템 정의
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(140))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.orthogonalScrollingBehavior = .continuous
        
        // 섹션 헤더 추가
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    
    // MARK: ✅ Configure Button Action
    private func configureButtonAction() {
        floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: ✅ Action Method - Floating Button 탭 시 호출
    @objc private func floatingButtonTapped() {
        // 감정일기를 작성하는 화면으로 이동하는 로직
        let diaryEditorVC = DiaryEditorViewController(mode: .create)
        let naviToDiaryEditorVC = UINavigationController(rootViewController: diaryEditorVC)
        naviToDiaryEditorVC.modalPresentationStyle = .fullScreen
        naviToDiaryEditorVC.modalTransitionStyle = .coverVertical
        present(naviToDiaryEditorVC, animated: true)
    }

}


// MARK: ✅ Extension - HomeSection + HomeItem (UI 섹션 정의)
extension HomeViewController {
    
    // Home 화면의 섹션 구분
    enum HomeSection: Int, CaseIterable {
        case quote
        case emotionSummary
        case recentEntries
        case photoGallery
        
        var title: String {
            switch self {
            case .quote:
                return NSLocalizedString("home_section_quote_title",
                                         comment: "Label for the quote section title")
            case .emotionSummary:
                return NSLocalizedString("home_section_emotion_summary_title",
                                         comment: "Label for weekly emotion summary section")
            case .recentEntries:
                return NSLocalizedString("home_section_recent_entries_title",
                                         comment: "Label for recent diary entries section")
            case .photoGallery:
                return NSLocalizedString("home_section_photo_gallery_title",
                                         comment: "Label for photo diary section")
            }
        }
        
        var subtitle: String {
            switch self {
            case .quote: return NSLocalizedString("home_section_quote_subtitle", comment: "Label for the quote section subTitle")
            case .emotionSummary: return NSLocalizedString("home_section_emotion_summary_subtitle", comment: "Label for weekly emotion summary section subTitle")
            case .recentEntries: return NSLocalizedString("home_section_recent_entries_subtitle", comment: "Label for recent diary entries section subTitle")
            case .photoGallery: return NSLocalizedString("home_section_photo_gallery_subtitle", comment: "Label for photo diary section subTitle")
            }
        }
    }
    
    // Home 화면의 각 섹션별 데이터 아이템
    enum HomeItem: Hashable, Sendable {
        case quote(HappinessQuote)
        case emotionSummary(WeeklyEmotionSummaryModel)
        case diary(EmotionDiaryModel)
        case photo(image: UIImage?, diaryID: String)
    }
}


// MARK: ✅ Extension - HomeItem 내의 emotionSummary 케이스 데이터타입
// 이 섹션에 들어가는 데이터는 총 3개 - 이를 묶을 목적으로 구조체 설정 
struct WeeklyEmotionSummaryModel: Hashable {
    let weekDescription: String
    let top3Emotion: [EmotionCategory]
    let mostFrequentByWeekday: [DiaryCoreDataManager.Weekday: EmotionCategory]
}



// MARK: ✅ Extension - Navigation 셋팅
extension HomeViewController {
    
    private func configureNavigation() {
        
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
        titleLabel.font = .systemFont(ofSize: 20, weight: .black)
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
            ("line.3.horizontal", #selector(didTapList)),
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

    // 리스트 버튼이 눌리면 동작하는 액션
    @objc private func didTapList() {
        print("📋 리스트 버튼 탭됨")
        // TODO: 목록 화면 이동
    }

    // 알람 버튼이 눌리면 동작하는 액션
    @objc private func didTapBell() {
        print("🔔 알림 버튼 탭됨")
        // TODO: 알림 화면 이동
    }

}
