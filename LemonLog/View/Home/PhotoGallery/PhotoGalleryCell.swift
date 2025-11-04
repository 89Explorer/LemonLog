//
//  PhotoGalleryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/3/25.
//

import UIKit

class PhotoGalleryCell: UICollectionViewCell {
    
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "PhotoGalleryCell"
    
    
    // MARK: ✅ Property
    private(set) var diaryID: String?
    
    
    // MARK: ✅ UI
    private var photoImageView: UIImageView = UIImageView()
    
    
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
        //contentView.backgroundColor = UIColor.vanillaCream
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowRadius = 8
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.cornerRadius = 4
        photoImageView.clipsToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            photoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            photoImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            
        ])
    }
    
    
    // MARK: ✅ Configure Data
    func configure(with image: UIImage?, diaryID: String) {
        self.photoImageView.image = image ?? UIImage(systemName: "photo") // fallback
        self.diaryID = diaryID
    }
    
}
