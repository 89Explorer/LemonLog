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
    
    
    // MARK: ✅ Closure
    var onTappedMove: (() -> Void)?
    
    
    // MARK: ✅ UI
    private let titleLabel: UILabel = UILabel()
    private let subTitleLabel: UILabel = UILabel()
    private let moveButton: UIButton = UIButton()
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setupTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ UI Setup
    private func configureUI() {
        self.backgroundColor = .clear
        
        let separtor: UIView = UIView(frame: .zero)
        separtor.backgroundColor = .quaternaryLabel
        separtor.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        
        subTitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        subTitleLabel.textColor = .secondaryLabel
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let moveImage = UIImage(systemName: "chevron.right", withConfiguration: config)
        
        moveButton.setImage(moveImage, for: .normal)
        moveButton.tintColor = .systemGray
        moveButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let subStackView: UIStackView = UIStackView(arrangedSubviews: [titleLabel, moveButton])
        subStackView.axis = .horizontal
        subStackView.spacing = 8
        subStackView.distribution = .fill
        subStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(subStackView)
        self.addSubview(subTitleLabel)
        self.addSubview(separtor)
        
        NSLayoutConstraint.activate([
            
            subStackView.topAnchor.constraint(equalTo: self.topAnchor),
            subStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            subTitleLabel.topAnchor.constraint(equalTo: subStackView.bottomAnchor, constant: 4),
            subTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            
            separtor.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 4),
            separtor.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            separtor.trailingAnchor.constraint(equalTo: subTitleLabel.trailingAnchor, constant: 4),
            separtor.heightAnchor.constraint(equalToConstant: 1),
            
        ])
        
    }
    
    
    // MARK: ✅ setupTapGesture -> 섹션헤더뷰를 누르면 호출되는 함수
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedMove))
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
    }
    
    
    // MARK: ✅ Configure Data to UI
    func configure(with title: String, subtitle: String) {
        titleLabel.text = title
        subTitleLabel.text = subtitle
    }
    
    
    // MARK: ✅ Action Method
    @objc private func tappedMove() {
        onTappedMove?()
    }
}
