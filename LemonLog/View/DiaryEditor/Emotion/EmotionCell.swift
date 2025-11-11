//
//  EmotionCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/11/25.
//

import UIKit


final class EmotionCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "EmotionCell"
    
    
    // MARK: ✅ Closure
    var onAddButtonTapped: (() -> Void)?
    
    
    // MAARK: ✅ UI
    private var addEmotionButton: UIButton!
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
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        addEmotionButton = UIButton(type: .system)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let addimage = UIImage(systemName: "plus", withConfiguration: imageConfig)
        addEmotionButton.setImage(addimage, for: .normal)
        addEmotionButton.tintColor = .black
        addEmotionButton.backgroundColor = .softMint
        addEmotionButton.layer.cornerRadius = 4
        addEmotionButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        addEmotionButton.translatesAutoresizingMaskIntoConstraints = false
        
        emotionImageView = UIImageView()
        emotionImageView.contentMode = .scaleAspectFit
        emotionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        
        contentView.addSubview(addEmotionButton)
        contentView.addSubview(emotionImageView)
        
        NSLayoutConstraint.activate([
            addEmotionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addEmotionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addEmotionButton.widthAnchor.constraint(equalToConstant: 36),
            addEmotionButton.heightAnchor.constraint(equalToConstant: 36),
            
            emotionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emotionImageView.leadingAnchor.constraint(equalTo: addEmotionButton.trailingAnchor, constant: 24),
            emotionImageView.widthAnchor.constraint(equalToConstant: 44),
            emotionImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    
    // MARK: ✅ Configure Data
    func configure(with emotion: EmotionCategory) {
        emotionImageView.image = emotion.emotionImage
    }
    
    
    // MARK: ✅ Action Method
    // UIKit에서는 Cell이 직접 present 하는 것은 피해야함
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
    
}
