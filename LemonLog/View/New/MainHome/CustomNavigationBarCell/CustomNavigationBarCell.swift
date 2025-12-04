//
//  CustomNavigationBarCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/2/25.
//

import UIKit


final class CustomNavigationBarCell: UICollectionViewCell {
    
    
    // MARK: ✅ Closure
    var onTapSearch: (() -> Void)?
    var onTapBell: (() -> Void)?
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "CustomNavigationBarCell"
    
    
    // MARK: ✅ UI
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "LemonLog"
        label.font = UIFont(name: "DungGeunMo", size: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        b.tintColor = .black
        return b
    }()
    
    private let bellButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "bell"), for: .normal)
        b.tintColor = .black
        return b
    }()
    
    private let leftStack = UIStackView()
    private let rightStack = UIStackView()
    private let container = UIStackView()
    
    
    // MARK: ✅ Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Setup Layout
    private func setupLayout() {
        
        // left stack: logo + title
        leftStack.axis = .horizontal
        leftStack.spacing = 6
        leftStack.alignment = .center
        leftStack.addArrangedSubview(logoImageView)
        leftStack.addArrangedSubview(titleLabel)
        
        // right stack: search + bell buttons
        rightStack.axis = .horizontal
        rightStack.spacing = 12
        rightStack.alignment = .center
        rightStack.addArrangedSubview(searchButton)
        rightStack.addArrangedSubview(bellButton)
        
        // total container
        container.axis = .horizontal
        container.alignment = .center
        container.distribution = .equalSpacing
        container.addArrangedSubview(leftStack)
        container.addArrangedSubview(rightStack)
        
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
    }
    
    
    // MARK: ✅ Add Action Buttons
    private func setupActions() {
        searchButton.addAction(UIAction { _ in self.onTapSearch?() }, for: .touchUpInside)
        bellButton.addAction(UIAction { _ in self.onTapBell?() }, for: .touchUpInside)
    }

    
    // MARK: ✅ Configure Data
    func configure() {
        let logo = UIImage(named: "lemon")?
            .resized(to: CGSize(width: 32, height: 32))
            .withRenderingMode(.alwaysOriginal)
        logoImageView.image = logo
    }
}
