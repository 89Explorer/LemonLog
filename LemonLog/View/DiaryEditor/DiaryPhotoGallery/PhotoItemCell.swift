//
//  PhotoItemCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/14/25.
//

import UIKit


final class PhotoItemCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "PhotoItemCell"
    
    
    // MARK: ✅ Closure
    var onRemove: (() -> Void)?
    
    
    // MARK: ✅ UI
    private let imageView: UIImageView = UIImageView()
    private let removeButton: UIButton = UIButton(type: .system)
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Configure UI
    private  func configureUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let removeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        removeButton.setImage(removeImage, for: .normal)
        removeButton.tintColor = .black
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.addTarget(self, action: #selector(handleRemove), for: .touchUpInside)
        
        contentView.addSubview(imageView)
        contentView.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            removeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            removeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            removeButton.widthAnchor.constraint(equalToConstant: 20),
            removeButton.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

    
    // MARK: ✅ Configure Data
    func configure(image: UIImage) {
        imageView.image = image
    }
    
    
    // MARK: ✅ Action Method
    @objc private func handleRemove() {
        onRemove?()
    }
}
