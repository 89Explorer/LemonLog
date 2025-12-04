//
//  CalendarDayCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/7/25.
//
import UIKit


final class CalendarDayCell: UICollectionViewCell {
    
    
    // MARK: ✅ reuseIdentifier
    static let reuseIdentifier = "CalendarDayCell"
    
    
    // MARK: ✅ UI
    private let dateLabel: UILabel = UILabel()
    private let emotionImageView: UIImageView = UIImageView()    //  감정 이모티콘
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        dateLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emotionImageView.contentMode = .scaleAspectFit
        emotionImageView.tintColor = .systemGreen
        emotionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [dateLabel, emotionImageView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
       
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            emotionImageView.widthAnchor.constraint(equalToConstant: 16),
            emotionImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    
    // MARK: ✅ Configure Data
    func configure(
        with date: Date?,
        in month: Date,
        isSelected: Bool,
        calendarVM: CalendarViewModel
    ) {
        guard let date else {
            dateLabel.text = ""
            contentView.backgroundColor = .clear
            return
        }
        
        // 날짜 표시
        let calendar = calendarVM.calendar
        
        let day = calendar.component(.day, from: date)
        dateLabel.text = "\(day)"
        
        // 요일별 색상 설정
        let index = calendarVM.rotatedWeekdayIndex(for: date)

        if index == 0 {              // 헤더 기준 첫 번째 요일 = Sunday
            dateLabel.textColor = .systemRed
        } else if index == 6 {       // 헤더 기준 마지막 요일 = Saturday
            dateLabel.textColor = .systemBlue
        } else {
            dateLabel.textColor = .label
        }

        
        // CalendarMode에 따라 표시 / 비표시
//        switch calendarVM.mode {
//        case .dateOnly:
//            emotionImageView.isHidden = true
//        case .withDiary:
//            emotionImageView.isHidden = false
//            emotionImageView.image = UIImage(systemName: "flag.fill")
//        }
        
        // 선택 상태, 다른 달 여부에 따른 시각적 표시
        if isSelected {
            contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.4)
            dateLabel.textColor = .black
        } else {
            contentView.backgroundColor = .clear
        }
    }

}
