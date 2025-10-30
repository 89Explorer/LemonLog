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
#if DEBUG
    private var homeVM = HomeViewModel.mock()
#else
    private var homeVM = HomeViewModel()
#endif

    
    // MARK: ✅ DiffableDataSource
    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!
    
    
    // MARK: ✅ Dependencies
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ UI
    private var homeCollectionView: UICollectionView!
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
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
            
            // UI 테스트용 배경색
            switch section {
            case .quote:
                guard case .quote(let quoteData) = itemIdentifier,
                      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuoteCell.reuseIdentifier, for: indexPath) as? QuoteCell else { return UICollectionViewCell() }
                cell.configure(with: quoteData)
                return cell
    
            case .emotionSummary:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentView.backgroundColor = .systemRed
                return cell
                
            case .recentEntries:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentView.backgroundColor = .systemBlue
                return cell
                
            case .photoGallery:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
                cell.contentView.backgroundColor = .systemGreen
                return cell
            }

        })
        
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) -> UICollectionReusableView? in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            guard let section = HomeSection(rawValue: indexPath.section) else { return nil }
            
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
        let summaryItems = homeVM.emotionSummary.map { "\($0.key.rawValue): \($0.value)" }
        snapshot.appendItems(summaryItems.map { .emotionSummary($0) }, toSection: .emotionSummary)
        
        // 3️⃣ 최근 일기
        snapshot.appendItems(homeVM.recentDiaries.map { .diary($0) }, toSection: .recentEntries)
        
        // 4️⃣ 사진 일기
        snapshot.appendItems(homeVM.diaryImages.map { .photo($0.diaryID) }, toSection: .photoGallery)
        
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

    
    
    // MARK: ✅ UI Setup
    private func configureUI() {
        view.backgroundColor = .secondarySystemBackground
        //view.backgroundColor = UIColor(named: "VanillaCream")
        
        homeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        homeCollectionView.showsVerticalScrollIndicator = false
        homeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        homeCollectionView.backgroundColor = .clear
        view.addSubview(homeCollectionView)
        
        NSLayoutConstraint.activate([
            homeCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            homeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        homeCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        homeCollectionView.register(QuoteCell.self, forCellWithReuseIdentifier: QuoteCell.reuseIdentifier)
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(140))
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
       
        // 1️⃣ 아이템 정의 (각 카드)
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.22),    // 한 줄에 4~5개 보이도록
            heightDimension: .fractionalHeight(1.0)
        )
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        // 아이템 간 간격 설정: 각 아이템 주변에 상,하,좌,우로 4 포인트의 여백 추가
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // 2️⃣ 그룹 정의
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)  // 카드 높이
        )
        
        // 수평 그룹 생성
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // 3️⃣ 섹션 정의
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 8
        
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
        
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
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
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
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
        case emotionSummary(String)
        case diary(EmotionDiaryModel)
        case photo(String)
    }
}

