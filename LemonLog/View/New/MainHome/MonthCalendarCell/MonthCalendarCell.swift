//
//  MonthCalendarCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/3/25.
//
// ▶️ MainHomeViewController 내에서 "달력" 섹션에 사용될 Cell ◀️

import UIKit
import Combine


final class MonthCalendarCell: UICollectionViewCell {
    
    
    // MARK: ✅ Data Source
    private var dataSource: UICollectionViewDiffableDataSource<MonthCalendarSection,MonthCalendarItem>!
    
    
    // MARK: ✅ CalendarViewModel
    private var calendarVM: CalendarViewModel!
    
    
    // MARK: ✅ Private Properties (데이터 캐싱 및 Combine 관리)
    private var cancellables = Set<AnyCancellable>()   // Combine 구독 관리
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "MonthCalendarCell"
    
    
    // MARK: ✅ UI
    private var monthCalendarCollectionView: UICollectionView!
    private var fullCalendarButton: UIButton!
    
    
    // MARK: ✅ Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Prepare For Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellables.removeAll()
    }
    
    
    // MARK: ✅ Configure Data
    func configure(with vm: CalendarViewModel) {
        self.calendarVM = vm
        cancellables.removeAll()   // 구독 초기화
        setupBindings()
        
        // 초기 Snapshot 적용
        applySnapshot(for: vm.currentMonth)
    }
    
    
    // MARK: ✅ Setup Binding
    private func setupBindings() {
        calendarVM.$currentMonth
            .receive(on: RunLoop.main)
            .sink { [weak self] newMonth in
                guard let self = self else { return }
                
                // applySnapshot 등록
                applySnapshot(for: newMonth)
            }
            .store(in: &cancellables)
    }
}


// MARK: ✅ Extension (Setup UI)
extension MonthCalendarCell {
    
    // Setup UI
    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = true
        
        setupCollectionView()
        setupFullCalendarButton()
        
    }
    
    // Setup CollectionView
    private func setupCollectionView() {
        monthCalendarCollectionView = UICollectionView(frame: .zero,  collectionViewLayout: createLayout())
        
        monthCalendarCollectionView.backgroundColor = .clear
        monthCalendarCollectionView.showsVerticalScrollIndicator = false
        monthCalendarCollectionView.alwaysBounceVertical = false
        monthCalendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        monthCalendarCollectionView.register(CalendarItemCell.self, forCellWithReuseIdentifier: CalendarItemCell.reuseIdentifier)
        
        contentView.addSubview(monthCalendarCollectionView)
    
        NSLayoutConstraint.activate([
            monthCalendarCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            monthCalendarCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            monthCalendarCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            monthCalendarCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    
        ])
    }
    
    // Setup FullCalendarButton
    private func setupFullCalendarButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        configuration.baseForegroundColor = .black
        configuration.cornerStyle = .capsule
        
        configuration.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        configuration.image = UIImage(systemName: "calendar")
        configuration.imagePadding = 4
        configuration.imagePlacement = .leading
        
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        configuration.preferredSymbolConfigurationForImage = imageConfig
        
        configuration.title = "전체 보기"
        configuration.attributedTitle?.font = UIFont(name: "DungGeunMo", size: 12)
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24)
        ])
    }
}


// MARK: ✅ Extension (monthCalendarCollectionView 설정)
extension MonthCalendarCell {
    
    // Setup DataSource
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<MonthCalendarSection, MonthCalendarItem>(
            collectionView: monthCalendarCollectionView, cellProvider: { [self] collectionView, indexPath, itemIdentifier in
                
                switch itemIdentifier {
                    
                    // Month 섹션
                case .month(let month):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CalendarItemCell.reuseIdentifier,
                        for: indexPath
                    ) as! CalendarItemCell
                    
                    let raw = self.calendarVM.headerTitle(for: month)   // 2025년 12월
                    let components = raw.components(separatedBy: " ")   // '2025년', '12월'
                    let monthOnly = components.last ?? raw              // '12월'
                    
                    let state = CalendarItemState(
                        section: .month,
                        isToday: false,
                        hasDiary: false
                    )
                    
                    cell.configure(
                        text: monthOnly,
                        state: state
                    )
                    return cell
                    
                    // Weak 섹션
                case .week(let symbol):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CalendarItemCell.reuseIdentifier,
                        for: indexPath
                    ) as! CalendarItemCell
                    
                    let state = CalendarItemState(
                        section: .week,
                        isToday: false,
                        hasDiary: false
                    )
                    
                    // "월요일" -> "월"
                    // "화요일" -> "호"
                    // "Sun" -> "S"
                    let processedSymbol: String
                    if symbol.hasSuffix("요일") {
                        processedSymbol = String(symbol.prefix(1))
                    } else {
                        processedSymbol = String(symbol.prefix(1))
                    }
                    
                    cell.configure(
                        text: processedSymbol,
                        state: state
                    )
                    return cell
                    
                    // Day 섹션
                case .day(_, let date):
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CalendarItemCell.reuseIdentifier,
                        for: indexPath
                    ) as! CalendarItemCell
                    
                    // 날짜 문자열
                    let text = date.map { "\(self.calendarVM.calendar.component(.day, from: $0))" } ?? ""
                    
                    // 오늘인지 체크
                    let isToday = date.map { self.calendarVM.isToday($0) } ?? false
                    
                    // 감정일기 있는 날짜인지? (이전 단계에서 diaryDates 받아옴)
                    //let hasDiary = date.map { self?.calendarVM.diaryDates.contains($0.stripped()) } ?? false
                    
                    let state = CalendarItemState(
                        section: .day,
                        isToday: isToday,
                        hasDiary: false
                    )
                    
                    cell.configure(text: text, state: state)
                    return cell
                }
            }
        )
    }
    
    // Apply Snapshot 
    private func applySnapshot(for month: Date) {
        var snapshot = NSDiffableDataSourceSnapshot<MonthCalendarSection, MonthCalendarItem>()
        
        snapshot.appendSections([.month, .week, .day])
        
        // Month Section
        snapshot.appendItems([.month(month)], toSection: .month)
        
        // Week Section
        let weekSymbols = calendarVM.weekdaySymbols()
        let weekItems = weekSymbols.map { MonthCalendarItem.week($0) }
        snapshot.appendItems(weekItems, toSection: .week)
        
        // Day Section
        let grid = calendarVM.daysGrid(in: month)
        
        let dayItems: [MonthCalendarItem] = grid.flatMap { row in
            row.map { MonthCalendarItem.day(id: UUID(), date: $0) }
        }
        snapshot.appendItems(dayItems, toSection: .day)
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
    
    // Create Layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [self] sectionIndex, _ in
            guard let section = MonthCalendarSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .month:
                return monthLayout()
            case .week:
                return weekLayout()
            case .day:
                return dayLayout()
            }
        }
    }
    
    // Month Layout
    private func monthLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(48)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 16, leading: 24, bottom: 8, trailing: 24)
        return section
    }
    
    // Week Layout
    private func weekLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .absolute(32.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(32.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        // 아이템 간 간격 추가
        //group.interItemSpacing = .fixed(2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 4, trailing: 16)
        return section
    }
    
    // Day Layout
    private func dayLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .absolute(36)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
    
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0),
                              heightDimension: .estimated(36)),
            subitems: [item]
        )
        
        //group.interItemSpacing = .fixed(2)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.contentInsets = .init(top: 0 , leading: 16, bottom: 8, trailing: 16)
        return section
    }

}


// MARK: ✅ Enum (MonthCalendarCell + CalendarItemCell에 쓰임)
// Enum - monthCalendarCollectionView에 쓰일 섹션 구분
enum MonthCalendarSection: Int, CaseIterable {
    case month    // 월
    case week     // 요일
    case day      // 일
}

// Enum - 섹션에 대한 아이템
enum MonthCalendarItem: Hashable {
    case month(Date)     // 해당 월의 대표 날짜 (예: 2025-12-01)
    case week(String)    // "일요일", "월요일", "화요일" ....
    case day(id: UUID, date: Date?)      // 실제 날짜 (없으면 nil: 공백)
}
