//
//  SelectEmotionCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/11/25.
//

import UIKit


// ▶️ EmotionViewController - emotionCollectionView에 사용되는 셀 
final class SelectEmotionCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "SelectEmotionCell"
    
    
    // MARK: ✅ UI
    private var emotionImageView: UIImageView!
    
    
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
        contentView.backgroundColor = .clear
        
        emotionImageView = UIImageView()
        emotionImageView.contentMode = .scaleAspectFit
        emotionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(emotionImageView)
        
        NSLayoutConstraint.activate([
            emotionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emotionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emotionImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emotionImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    
    // MARK: ✅ Configure Data
    func configure(with emotion: EmotionCategory) {
        emotionImageView.image = emotion.emotionImage
    }
}
