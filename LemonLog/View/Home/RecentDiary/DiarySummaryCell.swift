//
//  DiarySummaryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/3/25.
//

import UIKit

class DiarySummaryCell: UICollectionViewCell {
    
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "DiarySummaryCell"
    
    
    // MARK: ✅ UI
    private let dayLabel: UILabel = UILabel()
    private let emotionImage: UIImageView = UIImageView()
    private let diaryLabel: UILabel = UILabel()
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ PrepareForReuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dayLabel.text = nil
        emotionImage.image = nil
        diaryLabel.text = nil 
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        //contentView.backgroundColor = UIColor.vanillaCream
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        dayLabel.font = .systemFont(ofSize: 16, weight: .bold)
        dayLabel.textAlignment = .left
        dayLabel.numberOfLines = 1
        dayLabel.textColor = .label
        dayLabel.setContentHuggingPriority(.required, for: .vertical)
        dayLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        emotionImage.contentMode = .scaleAspectFit
        emotionImage.setContentHuggingPriority(.required, for: .vertical)
        emotionImage.setContentCompressionResistancePriority(.required, for: .vertical)
        emotionImage.translatesAutoresizingMaskIntoConstraints = false
        
        diaryLabel.font = .systemFont(ofSize: 12, weight: .regular)
        diaryLabel.textAlignment = .left
        diaryLabel.numberOfLines = 3
        diaryLabel.textColor = .label
        diaryLabel.lineBreakMode = .byTruncatingTail
        
        let innerStackView: UIStackView = UIStackView(arrangedSubviews: [dayLabel, emotionImage, diaryLabel])
        innerStackView.axis = .vertical
        innerStackView.alignment = .leading
        innerStackView.distribution = .fill
        innerStackView.spacing = 4
        innerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(innerStackView)
        
        NSLayoutConstraint.activate([
            innerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            innerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            innerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            innerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            emotionImage.widthAnchor.constraint(equalToConstant: 20),
            emotionImage.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    
    // MARK: ✅ Configure Data
    func configure(with data: EmotionDiaryModel, summary: String) {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M월 d일"
        
        let convertDate = dateFormatter.string(from: data.createdAt)
        dayLabel.text = convertDate
        
        //emotionImage.image = UIImage(named: data.emotion)
        diaryLabel.text = summary
        
    }
}
