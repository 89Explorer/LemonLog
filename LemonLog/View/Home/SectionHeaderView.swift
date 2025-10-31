//
//  SectionHeaderView.swift
//  LemonLog
//
//  Created by 권정근 on 10/30/25.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
        
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "SectionHeaderView"
    
    
    // MARK: ✅ UI
    private let titleLabel: UILabel = UILabel()
    private let subTitleLabel: UILabel = UILabel()
    
    
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
        self.backgroundColor = .clear
        
        let separtor: UIView = UIView(frame: .zero)
        separtor.backgroundColor = .quaternaryLabel
        
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        subTitleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        subTitleLabel.textColor = .secondaryLabel
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel, separtor])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            separtor.heightAnchor.constraint(equalToConstant: 1),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
        
    }
    
    
    // MARK: ✅ Configure Data to UI
    func configure(with title: String, subtitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subtitle
    }
}
