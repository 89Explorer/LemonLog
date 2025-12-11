//
//  DiaryDateCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/6/25.
//

import UIKit

class DiaryDateCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "DiaryDateCell"
    
    
    // MARK: ✅ Closure
    var onTapDate: (() -> Void)?
    
    
    // MARK: ✅ UI
    private let calendarImage: UIImageView = UIImageView()
    private let dateLabel: BasePaddingLabel = BasePaddingLabel()
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        configureTapGesture()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.clipsToBounds = true
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let calendar = UIImage(systemName: "calendar", withConfiguration: config)
        calendarImage.image = calendar
        calendarImage.tintColor = .black
        calendarImage.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont(name: "DungGeunMo", size: 16)
        dateLabel.textColor = .black
        dateLabel.textAlignment = .left
        dateLabel.isUserInteractionEnabled = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false 
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(calendarImage)
        
        NSLayoutConstraint.activate([
            
            calendarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            calendarImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            dateLabel.leadingAnchor.constraint(equalTo: calendarImage.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    
    // MARK: ✅ Configure Tap Gesture
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapDate))
        dateLabel.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: ✅ Action Method
    @objc private func didTapDate() {
        print("📅 달력 셀이 눌렸습니다.")
        onTapDate?()
    }
    
    
    // MARK: ✅ Configure Date
    func configure(date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .full     // 시스템 언어에 맞게 자동 포맷
        formatter.timeStyle = .none
        formatter.locale = Locale.autoupdatingCurrent   // 기기 설정에 맞춰 자동 변경
        
        dateLabel.text = formatter.string(from: date)
    }
    
}
