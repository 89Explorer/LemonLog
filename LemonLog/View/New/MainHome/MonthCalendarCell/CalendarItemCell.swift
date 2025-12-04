//
//  CalendarItemCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/3/25.
//
// ▶️ MonthCalendarCell 내의 monthCalendarCollectionView에 등록되어 "월","요일","일"에 공용으로 쓰일 셀 ◀️

import UIKit

final class CalendarItemCell: UICollectionViewCell {
    
    
    // MARK: ✅ Constraint (Month만 왼족 정렬, Week & Day는 가운데 정렬)
    private var centerConstraints: [NSLayoutConstraint] = []
    private var leadingConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: ✅ Data (캘린더에 표시될 내용을 담고 있는 프로퍼티)
    private var state: CalendarItemState = CalendarItemState(section: .day, isToday: false, hasDiary: false)
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "CalendarItemCell"
    
    
    // MARK: ✅ UI
    private let titleLabel: UILabel = UILabel()
    private let diaryDotView: UIView = UIView()  // 다이어리를 작성한 날짜에 표시
    private let isTodayView: UIView = UIView()   // 오늘 날짜를 표시
    
    private let topSeparator = CalendarItemCell.makeSeparator()
    private let bottomSeparator = CalendarItemCell.makeSeparator()
    
    
    // MARK: ✅ Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        state = CalendarItemState(section: .day, isToday: false, hasDiary: false)
        titleLabel.text = nil
        diaryDotView.isHidden = true
        isTodayView.isHidden = true
        
        topSeparator.isHidden = true
        bottomSeparator.isHidden = true
        
        //contentView.layer.borderWidth = 0.0
        //contentView.layer.borderColor = UIColor.clear.cgColor
        //contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .clear
    }
    
}


// MARK: ✅ Extension (Setup UI)
extension CalendarItemCell {
    
    // Setup UI
    private func setupUI() {
        contentView.backgroundColor = .clear

        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        diaryDotView.backgroundColor = .systemYellow
        diaryDotView.layer.cornerRadius = 4
        diaryDotView.isHidden = true
        diaryDotView.translatesAutoresizingMaskIntoConstraints = false
        
        isTodayView.backgroundColor = UIColor.sageGreen.withAlphaComponent(0.6)
        isTodayView.layer.cornerRadius = 8
        isTodayView.clipsToBounds = true
        isTodayView.isHidden = true
        isTodayView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(diaryDotView)
        contentView.addSubview(topSeparator)
        contentView.addSubview(bottomSeparator)
        contentView.addSubview(isTodayView)
        
        centerConstraints = [
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0)
        ]

        leadingConstraints = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]

        // 기본값은 day/week 기준이므로 center constraints 활성화
        NSLayoutConstraint.activate(centerConstraints)
        
        NSLayoutConstraint.activate([
            
            isTodayView.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            isTodayView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            isTodayView.widthAnchor.constraint(equalToConstant: 36),
            isTodayView.heightAnchor.constraint(equalToConstant: 20),
            
            topSeparator.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 2),
            
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 2),
            
            diaryDotView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            diaryDotView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            diaryDotView.widthAnchor.constraint(equalToConstant: 8),
            diaryDotView.heightAnchor.constraint(equalToConstant: 8)
        ])
        
    }
    
    // Apply Style
    private func applyStyle() {
        
        // Reset
        contentView.layer.borderWidth = 0.0
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = .clear
        
        diaryDotView.isHidden = true
        titleLabel.textColor = .black
        isTodayView.isHidden = true
        
        topSeparator.isHidden = true
        bottomSeparator.isHidden = true 
        
        NSLayoutConstraint.deactivate(centerConstraints)
        NSLayoutConstraint.deactivate(leadingConstraints)
        
        switch state.section {
        case .month:
            titleLabel.font = UIFont(name: "DungGeunMo", size: 24)
            titleLabel.textColor = .black
            titleLabel.textAlignment = .left
            contentView.layer.borderWidth = 0.0
            
            NSLayoutConstraint.activate(leadingConstraints)

        case .week:
            titleLabel.font = UIFont(name: "DungGeunMo", size: 12)
            titleLabel.textColor = .darkGray
            topSeparator.isHidden = false
            bottomSeparator.isHidden = false
            
            NSLayoutConstraint.activate(centerConstraints)
            
        case .day:
            titleLabel.font = UIFont(name: "DungGeunMo", size: 16)
            titleLabel.textColor = .black
            
            if state.isToday {
                isTodayView.isHidden = false
                //contentView.backgroundColor = UIColor.softMint.withAlphaComponent(0.4)
            }
            
            //diaryDotView.isHidden = !state.hasDiary
            diaryDotView.isHidden = false
            
            NSLayoutConstraint.activate(centerConstraints)
        }
    }
    
    // Configure Data
    func configure(
        text: String,
        state: CalendarItemState
    ) {
        self.state = state
        titleLabel.text = text
        applyStyle()
    }
}


// MARK: ✅ Extension (Helper 메서드)
extension CalendarItemCell {
    
    // separator를 생성하는 함수
    // 프로퍼티 초기화 시점에는 인스턴스 메서드를 호출할 수 없기 때문에 "static"으로 선언
    private static func makeSeparator() -> UIView {
        let v = UIView()
        v.backgroundColor = .lightGray
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
    
}


// MARK: ✅ Struct - CalendarItemState
struct CalendarItemState {
    
    var section: MonthCalendarSection      // "월", "요일", "일" 구분
    var isToday: Bool                      // "오늘" 여부
    var hasDiary: Bool                     // 다이어리 포함 여부
    
}
