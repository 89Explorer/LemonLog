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
    private var errorLabel: UILabel = UILabel()

    
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
        
        errorLabel.text = NSLocalizedString(
            "validation_error_emotion_required",
            comment: "Message shown when emotion is not selected"
        )
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        errorLabel.isHidden = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(addEmotionButton)
        contentView.addSubview(emotionImageView)
        contentView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            
            addEmotionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addEmotionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addEmotionButton.widthAnchor.constraint(equalToConstant: 36),
            addEmotionButton.heightAnchor.constraint(equalToConstant: 36),
            
            emotionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emotionImageView.leadingAnchor.constraint(equalTo: addEmotionButton.trailingAnchor, constant: 24),
            emotionImageView.widthAnchor.constraint(equalToConstant: 44),
            emotionImageView.heightAnchor.constraint(equalToConstant: 44),
            
            errorLabel.topAnchor.constraint(equalTo: addEmotionButton.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            
        ])
        
    }
    
    
    // MARK: ✅ Configure Data
    func configure(with emotion: EmotionCategory) {
        emotionImageView.image = emotion.emotionImage
        updateUI()
    }
    
    
    // MARK: ✅ showError
    func showError(message: String) {
        
        errorLabel.text = message
        errorLabel.isHidden = false
        
    }
    
    
    // MARK: ✅ clearError
    func clearError() {
        errorLabel.isHidden = true
    }
    
    
    // MARK: ✅ updaateUI
    func updateUI() {
        
        let hasEmotion = (emotionImageView.image != nil)
        
        // 감정 선택되어 있으면 error 숨김
        errorLabel.isHidden = hasEmotion
        
    }
    
    // 자동 호출용 메서드 - DiaryEditorVieController가 열리면, 감정을 선택할 수 있도록 호출되는 함수 
    func triggerOpenEmotionPicker() {
        onAddButtonTapped?()
    }
    

    // MARK: ✅ Action Method
    // UIKit에서는 Cell이 직접 present 하는 것은 피해야함
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
    
}
