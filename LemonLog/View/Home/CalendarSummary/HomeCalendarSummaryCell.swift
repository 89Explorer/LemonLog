//
//  HomeCalendarSummaryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/28/25.
//

import UIKit
import Combine


final class HomeCalendarSummaryCell: UICollectionViewCell {
    
    
    // MARK: - Data
    private var days: [Date?] = []
    
    
    // MARK: ✅ ViewModel & Cancellables
    private var dataSource: UICollectionViewDiffableDataSource<CalendarSection, CalendarItem>!
    private var calendarVM: CalendarViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ Static Reuseidentifier
    static let reuseIdentifier: String = "HomeCalendarSummaryCell"
    
    
    // MARK: ✅ UI
    private let monthLabel: UILabel = UILabel()
    private var calendarCollectionView: UICollectionView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupCollectionView()
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(with initializedDate: Date = Date(),
                   mode: CalendarMode = .withDiary,
                   onSelectedDate: @escaping (Date) -> Void
    ) {
        //self.calendarVM = CalendarViewModel(initialDate: initializedDate, mode: mode)
        self.days = calendarVM.days(in: initializedDate)
        setupDataSource()
        applySnapshot()
        bindViewModel()
    }

    // MARK: ✅ bindViewModel
    private func bindViewModel() {
        calendarVM.$currentMonth
            .receive(on: RunLoop.main)
            .sink { [weak self] month in
                guard let self else { return }
                let text = self.calendarVM.headerTitle(for: month)
                self.updateMonthLabel(with: text, for: month)
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        contentView.addSubview(monthLabel)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            monthLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12)
        ])
        
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<CalendarSection, CalendarItem>()
        snapshot.appendSections(CalendarSection.allCases)

        // 1️⃣ 요일 섹션
        let weekdays = calendarVM.weekdaySymbols()
        for (i, day) in weekdays.enumerated() {
            let isSunday = (i == 0 && calendarVM.calendar.firstWeekday == 1)
            let isSaturday = (i == 6)
            snapshot.appendItems([.weekday(day, isSunday: isSunday, isSaturday: isSaturday)], toSection: .weekday)
        }

        // 2️⃣ 날짜 섹션
        //let days = calendarVM.days(in: calendarVM.currentMonth)
        for date in days {
            snapshot.appendItems([.day(date, isSelected: false)], toSection: .days)
        }

        // 3️⃣ 감정일기 리스트 섹션 (당일 데이터)
        let diaries: [EmotionDiaryModel] = []// → viewModel에서 받아오기
        snapshot.appendItems(diaries.map { .diary($0) }, toSection: .diaryList)

        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(collectionView: calendarCollectionView) {
            collectionView, indexPath, item in

            switch item {

            case .weekday(let text, let isSunday, let isSaturday):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: WeekdayCell.reuseIdentifier,
                    for: indexPath
                ) as! WeekdayCell
                cell.configure(text: text, isSunday: isSunday, isSaturday: isSaturday)
                return cell

            case .day(let date, let isSelected):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CalendarDayCell.reuseIdentifier,
                    for: indexPath
                ) as! CalendarDayCell

                cell.configure(
                    with: date,
                    in: self.calendarVM.currentMonth,
                    isSelected: isSelected,
                    calendarVM: self.calendarVM
                )
                return cell


            case .diary(let diary):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
                return cell
            }
        }
    }


    
    private func updateMonthLabel(with text: String, for month: Date) {
        let nsText = text as NSString
        let calendar = calendarVM.calendar

        // 월 텍스트(각 언어)를 알아내기 위한 Formatter
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        let monthIndex = calendar.component(.month, from: month) - 1

        // 예: "11월", "November", "novembre", "11月"
        let monthCandidates = [
            formatter.monthSymbols[monthIndex],
            formatter.standaloneMonthSymbols[monthIndex]
        ]

        var monthText: String = text  // fallback

        // 주어진 text 안에서 month 문자열을 찾으면 그 부분만 사용
        for candidate in monthCandidates {
            let range = nsText.range(of: candidate)
            if range.location != NSNotFound {
                monthText = candidate
                break
            }
        }

        // 월 텍스트만 스타일 적용
        let attributed = NSMutableAttributedString(string: monthText)

        attributed.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.black
        ], range: NSMakeRange(0, monthText.count))

        monthLabel.attributedText = attributed
    }


    
    // MARK: ✅ setupCollectionView - calendarCollectionView 설정
    private func setupCollectionView() {
        calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        calendarCollectionView.backgroundColor = .clear
        
        calendarCollectionView.delegate = self
        
        calendarCollectionView.register(WeekdayCell.self, forCellWithReuseIdentifier: WeekdayCell.reuseIdentifier)
        calendarCollectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        calendarCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        calendarCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(calendarCollectionView)

        NSLayoutConstraint.activate([
            calendarCollectionView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 8),
            calendarCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            calendarCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            calendarCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    

    // MARK: ✅ createLayout - 섹션 별 레이아웃
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            guard let self else { return nil }
            
            switch sectionIndex {
                
            // 요일 셀 섹션
            case 0:
                return self.createWeekdaySection()
                
            // 날짜 셀 섹션
            case 1:
                return self.createDaySection()
                
            // 감정일기 리스트
            case 2:
                return self.createDiaryListSection()
                
            default:
                return nil
            }
        }
    }
    
    
    // MARK: ✅ createWeekdaySection - 요일 표시 섹션
    private func createWeekdaySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(24)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16)
        return section
    }

    
    
    // MARK: ✅ createDaySection - 날짜 표시 섹션
    private func createDaySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0 / 7.0),
            heightDimension: .fractionalWidth(1.0 / 7.0)     // 정사각형
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)   // 적절한 크기로 설정 가능
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 4
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16)
        return section
    }

    
    
    // MARK: ✅ createDiaryListSection - 감정일기 리스트 섹션
    private func createDiaryListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)    // 동적 높이
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        section.interGroupSpacing = 6
        return section
    }
    
}


extension HomeCalendarSummaryCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .day(let date, _):
            if let date {
                print("선택한 날짜: \(date)")
                // TODO: selectedDate = date
                // TODO: applySnapshot() 호출해서 선택 상태 반영
            }
        default:
            break
        }
    }
}



// MARK: Enum - calendarCollectionView 섹션
enum CalendarSection: Int, CaseIterable {
    case weekday   // 요일
    case days      // 날짜
    case diaryList // 감정일기 리스트
}


// MARK: Enmum - CalendarSection 내의 아이템 정보
enum CalendarItem: Hashable {
    case weekday(String, isSunday: Bool, isSaturday: Bool)
    case day(Date?, isSelected: Bool)
    case diary(EmotionDiaryModel)
}
