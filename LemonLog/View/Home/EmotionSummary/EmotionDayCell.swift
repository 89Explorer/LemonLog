//
//  EmotionDayCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/2/25.
//

import UIKit

class EmotionDayCell: UICollectionViewCell {
    
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "EmotionDayCell"
    
    
    // MARK: ✅ UI
    private let dayLabel: UILabel = UILabel()
    private let seperator: UIView = UIView()
    private let emotionView: UIImageView = UIImageView()
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
        contentView.layer.cornerRadius = 8
        
        dayLabel.font = .systemFont(ofSize: 12, weight: .bold)
        dayLabel.textAlignment = .center
        dayLabel.numberOfLines = 1
        dayLabel.textColor = .label
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        seperator.backgroundColor = .black
        
        emotionView.contentMode = .scaleAspectFit
        
        let innerStackView: UIStackView = UIStackView(arrangedSubviews: [dayLabel, seperator, emotionView])
        innerStackView.axis = .vertical
        innerStackView.spacing = 4
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(innerStackView)
        
        NSLayoutConstraint.activate([
            innerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            innerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            innerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            innerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            seperator.heightAnchor.constraint(equalToConstant: 1),
            
            emotionView.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    
    // MARK: ✅ Configure Data
    func configure(dayText: String, emotion: EmotionCategory?) {
        dayLabel.text = dayText
        
        if let emotion {
            emotionView.image = emotion.emotionImage
            emotionView.alpha = 1.0
        } else {
            emotionView.image = nil
            emotionView.alpha = 0.15
        }
    }
}
