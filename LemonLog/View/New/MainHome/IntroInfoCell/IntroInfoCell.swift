//
//  IntroInfoCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/2/25.
//

import UIKit

class IntroInfoCell: UICollectionViewCell {
    
    
    // MARK: ✅ Closure
    var onTapStartDiary: (() -> Void)?
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "IntroInfoCell"
    
    
    // MARK: ✅ UI
    private let cardView: UIView = {
        let v = UIView()
        //v.backgroundColor = UIColor(red: 248/255, green: 247/255, blue: 255/255, alpha: 1)
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2

        // 전체 기본 스타일
        let fullText = "안녕하세요 😀,\nLemonLog 사용자님"
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont(name: "DungGeunMo", size: 20)!,
                .foregroundColor: UIColor.black
            ]
        )
        
        // 1) "LemonLog" 스타일 변경
        let lemonRange = (fullText as NSString).range(of: "LemonLog")
        attributed.addAttributes([
            .font: UIFont(name: "DungGeunMo", size: 16)!
        ], range: lemonRange)
        
        // 2) "사용자" 스타일 변경
        let userRange = (fullText as NSString).range(of: "사용자")
        attributed.addAttributes([
            .foregroundColor: UIColor.systemYellow,
            .font: UIFont(name: "DungGeunMo", size: 24)!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ], range: userRange)

        
        label.attributedText = attributed
        return label
    }()
    
    private let quoteLabel: UILabel = {
        let label = UILabel()
        label.text = "\"감정은 내가 누구인지 알려주는 나침반입니다.\""
        label.font = UIFont(name: "DungGeunMo", size: 16)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let startButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 32, bottom: 12, trailing: 32)
        
        // 폰트 적용된 Attributed Title 설정
        let title = "+ 감정일기 시작하기"
        let attrTitile = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: UIFont(name: "DungGeunMo", size: 16)!
            ])
        )
        config.attributedTitle = attrTitile
        
        let button = UIButton(configuration: config)
        button.layer.shadowColor = UIColor.systemYellow.withAlphaComponent(0.5).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        return button
    }()
    
    
    // MARK: ✅ Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Setup UI
    private func setupUI() {
        contentView.addSubview(cardView)
        [greetingLabel, quoteLabel, startButton].forEach { cardView.addSubview($0) }
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            greetingLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            greetingLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            greetingLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            
            //quoteLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 8),
            quoteLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            quoteLabel.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -20),
            
            startButton.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 20),
            startButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 40),
            startButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }
    
    
    // MARK: ✅ Actions
    private func setupActions() {
        startButton.addAction(UIAction(handler: { [weak self] _ in
            self?.onTapStartDiary?()
        }), for: .touchUpInside)
    }
    
    
    // MARK: ✅ Configure Data
    func configure(quote: String) {
        quoteLabel.text = "\"\(quote)\""
    }
}
