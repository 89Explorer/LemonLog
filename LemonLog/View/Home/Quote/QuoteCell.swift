//
//  QuoteCell.swift
//  LemonLog
//
//  Created by 권정근 on 10/29/25.
//

import UIKit


// MARK: - Class (명언 섹션에 대응하는 셀)
class QuoteCell: UICollectionViewCell {
    
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "QuoteCell"
    
    
    // MARK: ✅ Closure
    var onTapRefresh: (() -> Void)?
    
    
    // MARK: ✅ UI
    private let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.cornerRadius = 24
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemGray.cgColor
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let titleLabel: UILabel = UILabel()
    private let quoteLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let iconView: UIImageView = UIImageView(image: UIImage(systemName: "leaf.fill"))
    private let refreshButton: UIButton = UIButton(type: .system)
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ UI Setup
    private func configureUI() {
        //contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.5)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 32
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.layer.masksToBounds = true
//        contentView.layer.cornerRadius = 16
//        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
//        contentView.layer.shadowOpacity = 0.3
//        contentView.layer.shadowRadius = 8
//        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        iconView.tintColor = .systemGreen
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = NSLocalizedString("home_section_quote_title", comment: "")
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        quoteLabel.font = .systemFont(ofSize: 16, weight: .bold)
        quoteLabel.textColor = .label
        quoteLabel.textAlignment = .left
        quoteLabel.numberOfLines = 0
        quoteLabel.lineBreakMode = .byWordWrapping
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel.font = .systemFont(ofSize: 12, weight: .black)
        authorLabel.textColor = .secondaryLabel
        authorLabel.textAlignment = .center
        authorLabel.numberOfLines = 1
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [quoteLabel, authorLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 16)
        let refreshImage = UIImage(systemName: "arrow.clockwise.circle", withConfiguration: config)
        refreshButton.setImage(refreshImage, for: .normal)
        refreshButton.tintColor = .systemGray
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        refreshButton.addTarget(self, action: #selector(tappedRefresh), for: .touchUpInside)
        
        contentView.addSubview(bgView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(quoteLabel)
        bgView.addSubview(authorLabel)
        bgView.addSubview(refreshButton)
        
        NSLayoutConstraint.activate([
            
            bgView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            bgView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            bgView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            bgView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            
            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 12),
            
            quoteLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            quoteLabel.trailingAnchor.constraint(equalTo: bgView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            quoteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            quoteLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            authorLabel.topAnchor.constraint(equalTo: quoteLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            authorLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            
            refreshButton.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -12),
            refreshButton.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -12),
            refreshButton.widthAnchor.constraint(equalToConstant: 24),
            refreshButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
    }
    
    
    // MARK: ✅ UI에 전달하는 함수 
    func configure(with data: HappinessQuote) {
        let quote = data.content
        let author = data.author
        
        quoteLabel.text = "“\(quote)”"
        authorLabel.text = "- \(author) -"
    }
    
    
    // MARK: ✅ Action Method
    @objc private func tappedRefresh() {
        onTapRefresh?()
    }
    
}
