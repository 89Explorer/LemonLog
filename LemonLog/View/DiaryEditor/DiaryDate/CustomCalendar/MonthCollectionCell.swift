//
//  MonthCollectionCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/7/25.
//

import UIKit
import Combine


final class MonthCollectionCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier = "MonthCollectionCell"
    
    
    // MARK: ✅ Closure
    // 날짜 선택 시 부모로 전달 (외부로 전달)
    var onSelectDate: ((Date) -> Void)?
    
    
    // MARK: ✅ Property
    // 현재 선택된 날짜 (이 셀이 닫혔다가 다시 열려도 유지목적)
    var selectedDate: Date?
    private var month: Date?
    private var days: [Date?] = []
    
    
    // MARK: ✅ ViewModel & Cancellables
    private weak var viewModel: CalendarViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: ✅ UI
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.isScrollEnabled = false  // 한 달 달력은 스크롤 안 되도록
        cv.register(CalendarDayCell.self, forCellWithReuseIdentifier: CalendarDayCell.reuseIdentifier)
        return cv
    }()


    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    
    // MARK: ✅ Configure UI
    private func configureUI() {
        
        contentView.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    
    // MARK: ✅ Create Layout
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, env in
            
            // 아이템 크기 (한 행에 7일, 즉 7열)
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / 7.0),
                heightDimension: .absolute(28)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // 각 셀(날짜) 간 약간의 여백
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
            
            // 7열로 구성된 한 줄(=1주)을 하나의 그룹으로
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(280)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 7
            )
            
            // 주 단위 그룹 간 간격 및 전체 인셋 설정
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.interGroupSpacing = 4
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            return sectionLayout
        }
    }

    
    // MARK: ✅ Configure Data
    func configure(month: Date, viewModel: CalendarViewModel, initialSelectedDate: Date?) {
        
        self.month = month
        self.viewModel = viewModel
        self.days = viewModel.days(in: month)

        // 최초 로드일 때만 “오늘”을 기본 선택
        if selectedDate == nil {
            if let initial = initialSelectedDate {
                // 초기 선택값이 현재 달에 속하면 그걸 선택
                // 예) 사용자가 선택한 날자가 11월 10일 경우,
                // [이전달, 이번달, 다음달]로 "달" 구성 -> isSameMonth메서드를 통해 "달"이 같은 날만 표기하기 위함
                if viewModel.isSameMonth(initial, as: month) {
                    selectedDate = initial
                }
            } else {
                // 초기 선택값이 없을 경우 “오늘” 날짜만 표시 (선택 X)
                selectedDate = nil
            }
        }

        collectionView.reloadData()
    }
}


// MARK: ✅ Extension - UICollectionViewDataSource
extension MonthCollectionCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        days.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarDayCell.reuseIdentifier,
            for: indexPath
       ) as? CalendarDayCell else { return UICollectionViewCell() }
        
        guard let month, let vm = viewModel else { return cell }
        let date = days[indexPath.item]
        
        let isSelected: Bool = {
            guard let d = date, let sel = selectedDate else { return false }
            // ✅ 같은 Calendar 기준으로 same-day 비교
            return vm.calendar.isDate(d, inSameDayAs: sel)
        }()
        
        cell.configure(
            with: date,
            in: month,
            isSelected: isSelected,
            calendarVM: vm
        )
        
        return cell
    }

}


// MARK: ✅ Extension - UICollectionViewDelegate
extension MonthCollectionCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let date = days[indexPath.item] else { return }
        selectedDate = date
        collectionView.reloadData()
        onSelectDate?(date) // 호출측이 이 값을 보관해서 다음 오픈 때 initialSelectedDate로 넘겨줘야 함
    }
    
}

