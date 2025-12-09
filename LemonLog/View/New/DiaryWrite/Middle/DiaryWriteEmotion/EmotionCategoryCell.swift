//
//  EmotionCategoryCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/7/25.
//
// ▶️ emotionCollectionView에 "대분류" 감정을 나타내는 셀 ◀️


import UIKit


final class EmotionCategoryCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "EmotionCategoryCell"
    
    
    // MARK: ✅ UI
    // baseContainer = emojiLabel + titleLabel
    private let baseContainer: UIView = UIView()
    private let emojiLabel: UILabel = UILabel()
    private let titleLabel: UILabel = UILabel()
    
    // subContainer = subEmotionStack 포함
    private let subContainer: UIView = UIView()
    private let subEmotionStack: UIStackView = UIStackView()
    
    
    // MARK: ✅ State
    private var subEmotions: [String] = []
    private var selectedSubEmotions: Set<String> = []
    private var expanded: Bool = false
    
    private var isSelectionEnabled: Bool = true
    
    
    // MARK: ✅ Call Back (상위 뷰에 선택 결과 전달)
    var onSelectSubEmotion: (([String]) -> Void)?
    
    
    // MARK: ✅ Initilization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: ✅ Configure Data
    func configure(category: EmotionCategory, expanded: Bool, selected: [String]) {
        let meta = category.meta

        self.expanded = expanded
        self.selectedSubEmotions = Set(selected)
        self.subEmotions = meta.subEmotions
        
        // 기본 UI 설정
        emojiLabel.text = meta.emoji
        titleLabel.text = meta.displayName
        
        // 배경색
        let targetColor = expanded
        ? meta.backgroundColor.withAlphaComponent(0.25)
        : meta.backgroundColor
        
        baseContainer.backgroundColor = targetColor
        subContainer.backgroundColor = targetColor
        
        // UI 토글
        baseContainer.alpha = expanded ? 0 : 1
        subContainer.alpha = expanded ? 1 : 0
        
        updateSubEmotionButtons()
        
        UIView.animate(withDuration: 0.55) {
            self.layoutIfNeeded()
        }
        
    }
    
    // fade-in/out 전담
    func animateToggle(expanded: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.baseContainer.alpha = expanded ? 0 : 1
            self.subContainer.alpha = expanded ? 1 : 0
        }
    }


}


// MARK: ✅ Extension (UI 구성)
extension EmotionCategoryCell {
    
    private func setupUI() {
        
        // Base Container (emoji + title)
        baseContainer.layer.cornerRadius = 16
        baseContainer.clipsToBounds = true
        
        emojiLabel.font = UIFont.systemFont(ofSize: 36)
        emojiLabel.textAlignment = .center
        
        titleLabel.font = UIFont(name: "DungGeunMo", size: 18)
        titleLabel.textAlignment = .center
        
        // Sub Container
        subContainer.layer.cornerRadius = 16
        subContainer.clipsToBounds = true
        subContainer.alpha = 0
        
        // Stack for buttons
        subEmotionStack.axis = .vertical
        subEmotionStack.spacing = 8
        
        // Add Views
        contentView.addSubview(baseContainer)
        contentView.addSubview(subContainer)
        
        baseContainer.addSubview(emojiLabel)
        baseContainer.addSubview(titleLabel)
        
        subContainer.addSubview(subEmotionStack)
    }

}


// MARK: ✅ Extension (AutoLayout 구성)
extension EmotionCategoryCell {
    
    private func setupLayout() {
          
          [baseContainer, emojiLabel, titleLabel,
           subContainer, subEmotionStack].forEach {
              $0.translatesAutoresizingMaskIntoConstraints = false
          }
          
          NSLayoutConstraint.activate([
              
              // baseContainer — collapsed 상태 UI
              baseContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
              baseContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
              baseContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
              baseContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
              
              emojiLabel.topAnchor.constraint(equalTo: baseContainer.topAnchor, constant: 12),
              emojiLabel.centerXAnchor.constraint(equalTo: baseContainer.centerXAnchor),
              
              titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
              titleLabel.centerXAnchor.constraint(equalTo: baseContainer.centerXAnchor),
              titleLabel.bottomAnchor.constraint(equalTo: baseContainer.bottomAnchor, constant: -12),
              
              
              // subContainer — expanded 상태 UI
              subContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
              subContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
              subContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
              subContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
              
              subEmotionStack.topAnchor.constraint(equalTo: subContainer.topAnchor, constant: 12),
              subEmotionStack.leadingAnchor.constraint(equalTo: subContainer.leadingAnchor, constant: 12),
              subEmotionStack.trailingAnchor.constraint(equalTo: subContainer.trailingAnchor, constant: -12),
              subEmotionStack.bottomAnchor.constraint(equalTo: subContainer.bottomAnchor, constant: -12)
          ])
      }

}


// MARK: ✅ Extension (subEmotionStack 구성)
extension EmotionCategoryCell {
    
    private func updateSubEmotionButtons() {
        
        subEmotionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for emotion in subEmotions {
            let btn = UIButton(type: .system)
            btn.setTitle(emotion, for: .normal)
            btn.titleLabel?.font = UIFont(name: "DungGeunMo", size: 12)
            btn.layer.cornerRadius = 10
            btn.layer.borderWidth = 1
            
            let isSelected = selectedSubEmotions.contains(emotion)
            btn.backgroundColor = isSelected
            ? UIColor.systemPurple.withAlphaComponent(0.2)
            : .clear
            
            btn.layer.borderColor = isSelected
            ? UIColor.systemPurple.cgColor
            : UIColor.systemGray4.cgColor
            
            btn.setTitleColor(isSelected ? .systemPurple : .darkGray, for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            btn.isUserInteractionEnabled = isSelectionEnabled
            btn.alpha = isSelectionEnabled ? 1 : 0.4
            
            btn.addAction(UIAction { [weak self] _ in
                self?.toggleSubEmotion(emotion)
            }, for: .touchUpInside)
            
            subEmotionStack.addArrangedSubview(btn)
        }
    }
    
    private func toggleSubEmotion(_ item: String) {
        
        onSelectSubEmotion?([item])   // 배열로 보내는 이유: 일관성 유지
        
    }
    
    func setSelectionEnabled(_ allowed: Bool) {
        isSelectionEnabled = allowed
        updateSubEmotionButtons()   // 버튼 UI 업데이트
    }
    
}
