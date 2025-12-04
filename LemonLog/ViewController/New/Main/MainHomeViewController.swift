//
//  MainHomeViewController.swift
//  LemonLog
//
//  Created by 권정근 on 12/1/25.
//

import UIKit
import Combine


final class MainHomeViewController: UIViewController {
    
    
    // MARK: ✅ ViewModel
    private let mainHomeVM: MainHomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Data Source
    private var dataSource: UICollectionViewDiffableDataSource<MainHomeSection, MainHomeItem>!
    
    
    // MARK: ✅ UI
    private var mainCollectionView: UICollectionView!
    
    
    // MARK: ✅ Initialization
    init(viewModel: MainHomeViewModel) {
        self.mainHomeVM = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
        applyInitialSnapshot()
        bindViewModel()
    }
}


// MARK: ✅ Extension (바인딩 설정)
extension MainHomeViewController {
    
    // MainHomeVM 내부에 있는 QuoteVM의 todayQuote를 구독
    private func bindViewModel() {
        mainHomeVM.quoteVM.$todayQuote
            .sink { [weak self] quote in
                // 새 명언이 도착하면 updateIntroInfo 메서드에 전달
                self?.updateintroinfo(quote: quote)
            }
            .store(in: &cancellables)
    }
}


// MARK: ✅ Extension (UI 설정)
extension MainHomeViewController {
    
    // Setup UI
    private func setupUI() {
        view.backgroundColor = .clear
        setupCollectionView()
        setupStatusBarBackground()
    }
    
    // Setup Main CollectionView
    private func setupCollectionView() {
        mainCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        
        mainCollectionView.backgroundColor = .vanillaCream
        mainCollectionView.alwaysBounceVertical = true
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        mainCollectionView.register(CustomNavigationBarCell.self, forCellWithReuseIdentifier: CustomNavigationBarCell.reuseIdentifier)
        mainCollectionView.register(IntroInfoCell.self, forCellWithReuseIdentifier: IntroInfoCell.reuseIdentifier)
        mainCollectionView.register(MonthCalendarCell.self, forCellWithReuseIdentifier: MonthCalendarCell.reuseIdentifier)
        
        view.addSubview(mainCollectionView)
        
        NSLayoutConstraint.activate([
            mainCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    // Setup Status Bar
    private func setupStatusBarBackground() {
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 48

        let statusBarView = UIView()
        //statusBarView.backgroundColor = UIColor(red: 242/255, green: 230/255, blue: 198/255, alpha: 1.0)
        statusBarView.backgroundColor = .vanillaCream
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(statusBarView)

        NSLayoutConstraint.activate([
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBarView.heightAnchor.constraint(equalToConstant: statusBarHeight)
        ])
    }

}


// MARK: ✅ Extension (mainCollectionView 설정)
extension MainHomeViewController {
    
    // Setup Data Source
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MainHomeSection, MainHomeItem>(
            collectionView: mainCollectionView
        ) { [self] collectionView, indexPath, itemIdentifier in
            
            guard self != nil else { return UICollectionViewCell() }
            
            switch itemIdentifier {
            case .customNavigationBar:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CustomNavigationBarCell.reuseIdentifier,
                    for: indexPath
                ) as! CustomNavigationBarCell
                cell.configure()
                cell.onTapSearch = {
                    print("검색 버튼 눌림")
                }
                cell.onTapBell = {
                    print("알림 버튼 눌림")
                }
                return cell
                
            case .introInfo(let quote):
                
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: IntroInfoCell.reuseIdentifier,
                    for: indexPath
                ) as! IntroInfoCell
                
                let text = quote?.text ?? ""
                cell.configure(quote: text)
                return cell
                
            case .calendar(let date):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MonthCalendarCell.reuseIdentifier,
                    for: indexPath
                ) as! MonthCalendarCell
                
                cell.configure(with: mainHomeVM.calendarVM)
                return cell
            }
        }
        
    }
    
    // Apply Snapshot
    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<MainHomeSection, MainHomeItem>()
        
        // Custom NavigationBar
        snapshot.appendSections([.customNavigationBar])
        snapshot.appendItems([.customNavigationBar], toSection: .customNavigationBar)
        
        // IntroInfo
        snapshot.appendSections([.introInfo])
        snapshot.appendItems([.introInfo(quote: nil)], toSection: .introInfo)
        
        // Calendar
        snapshot.appendSections([.calendar])
        snapshot.appendItems([.calendar(mainHomeVM.calendarVM.currentMonth)], toSection: .calendar)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // Update IntroInfo
    private func updateintroinfo(quote: CustomQuote?) {
        var snapshot = dataSource.snapshot()
        
        // .Introinfo 섹션에서 기존 아이템을 찾습니다.
        let introInfoItems = snapshot.itemIdentifiers(inSection: .introInfo)
        
        // 기존 IntroInfo 아이템을 스냅삿에서 삭제
        if let existingItem = introInfoItems.first {
            
            // 기존 아이템 삭제
            snapshot.deleteItems([existingItem])
        }
        
        // 새로운 명언 데이터를 가진 아이템을 생성
        let updatedIte = MainHomeItem.introInfo(quote: quote)
        
        // 새로운 아이템을 .introInfo 섹션에 추가
        snapshot.appendItems([updatedIte], toSection: .introInfo)

        // 스냅샷 적용
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // Create Layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = MainHomeSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .customNavigationBar:
                return self.customNaviLayout()
            case .introInfo:
                return self.introInfoLayout()
            case .calendar:
                return self.calendarLayout()
            }
        }
    }
    
    // CustomNavigationBar Layout
    private func customNaviLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(52)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(52)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
        return section
        
    }
    
    // InfoIntro Layout
    private func introInfoLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(220)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
        return section
    }
    
    // Calendar Layout
    private func calendarLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(320)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 20, trailing: 20)
        return section
    }
    
}



// MARK: ✅ Extension (mainCollectionView에 쓰일, 섹션 & 아이템)
extension MainHomeViewController {
    
    // Enum - Section
    enum MainHomeSection: Int, CaseIterable {
        case customNavigationBar
        case introInfo
        case calendar
        //case infoAndCreate
    }
    
    // Enum - Item
    enum MainHomeItem: Hashable {
        case customNavigationBar
        case introInfo(quote: CustomQuote?)
        case calendar(Date)
    }
}
