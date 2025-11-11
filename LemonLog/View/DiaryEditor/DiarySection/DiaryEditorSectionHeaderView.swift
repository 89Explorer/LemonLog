//
//  DiaryEditorSectionHeaderView.swift
//  LemonLog
//
//  Created by 권정근 on 11/6/25.
//

import UIKit

class DiaryEditorSectionHeaderView: UICollectionReusableView {
        
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "DiaryEditorSectionHeaderView"
    
    
    // MARK: ✅ UI
    private let titleLabel: UILabel = UILabel()
    
    
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
        self.backgroundColor = .clear
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        let separtor: UIView = UIView(frame: .zero)
        separtor.backgroundColor = .secondaryLabel
        
        let stackView: UIStackView = UIStackView(arrangedSubviews: [titleLabel, separtor])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            //stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separtor.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    
    // MARK: ✅ Configure Data to UI
    func configure(with title: String) {
        titleLabel.text = title
    }
}
