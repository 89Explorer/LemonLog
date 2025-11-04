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
    
    
    // MARK: ✅ UI
    private let quoteLabel: UILabel = UILabel()
    private let authorLabel: UILabel = UILabel()
    private let iconView: UIImageView = UIImageView(image: UIImage(systemName: "leaf.fill"))
    private let refreshIconView: UIImageView = UIImageView(image: UIImage(systemName: "arrow.clockwise.circle"))
    
    
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
        //contentView.backgroundColor = UIColor.vanillaCream
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        iconView.tintColor = .systemGreen
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        quoteLabel.font = .systemFont(ofSize: 16, weight: .black)
        quoteLabel.textColor = .label
        quoteLabel.textAlignment = .left
        quoteLabel.numberOfLines = 0
        quoteLabel.lineBreakMode = .byWordWrapping
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        authorLabel.font = .systemFont(ofSize: 16, weight: .black)
        authorLabel.textColor = .label
        authorLabel.textAlignment = .center
        authorLabel.numberOfLines = 1
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [iconView, quoteLabel, authorLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        
        stackView.setCustomSpacing(4, after: quoteLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        refreshIconView.tintColor = .secondaryLabel
        refreshIconView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        contentView.addSubview(refreshIconView)
        
        NSLayoutConstraint.activate([
            
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            iconView.heightAnchor.constraint(equalToConstant: 20),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            
            refreshIconView.topAnchor.constraint(equalTo: authorLabel.topAnchor),
            refreshIconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            refreshIconView.widthAnchor.constraint(equalToConstant: 20),
            refreshIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
    }
    
    
    // MARK: ✅ UI에 전달하는 함수 
    func configure(with data: HappinessQuote) {
        let quote = data.content
        let author = data.author
        
        quoteLabel.text = "“\(quote)”"
        authorLabel.text = "- \(author) -"
    }
    
}
