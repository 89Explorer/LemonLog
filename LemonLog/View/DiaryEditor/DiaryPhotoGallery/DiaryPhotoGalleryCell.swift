//
//  DiaryPhotoGalleryCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/14/25.
//

import UIKit


final class DiaryPhotoGalleryCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "DiaryPhotoGalleryCell"
    
    
    // MARK: ✅ Closure
    var onRequestPhotoLibrary: (() -> Void)?
    var onRequestCamera: (() -> Void)?
    var onRequestDocument: (() -> Void)?
    var onPreviewRequested: (([UIImage], Int) -> Void)?   // (전체 이미지, 선택한 인덱스)
    var onImagesUpdated: (([UIImage]) -> Void)?           // 선택된 이미지 전달 목적
    var onAddPhotoTapped: (() -> Void)?

    
    // MARK: ✅ Property
    private var images: [UIImage] = []
    
    // 기본 최대 3장, StoreKit 구매 시 상위 VC에서 바꿔줄 예정
    var maxImageCount: Int = 3
    
    
    // MARK: ✅ UI
    private var addPhotoButton: UIButton!
    private var photoCollectionView: UICollectionView!
    
    
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
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        // addPhotoButton -------------------------------------------------------------
        addPhotoButton = UIButton(type: .system)
        setupAddPhotoButtonUI()
        updateAddPhotoCount()
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        
        // photoCollectionView --------------------------------------------------------
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 120)
        layout.minimumLineSpacing = 8
        
        photoCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        photoCollectionView.showsHorizontalScrollIndicator = false
        photoCollectionView.backgroundColor = .clear
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        photoCollectionView.translatesAutoresizingMaskIntoConstraints = false
        photoCollectionView.register(PhotoItemCell.self, forCellWithReuseIdentifier: PhotoItemCell.reuseIdentifier)
        
        contentView.addSubview(addPhotoButton)
        contentView.addSubview(photoCollectionView)
        
        NSLayoutConstraint.activate([
            
            addPhotoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            addPhotoButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 60),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 60),
            
            photoCollectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            photoCollectionView.leadingAnchor.constraint(equalTo: addPhotoButton.trailingAnchor, constant: 12),
            photoCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            photoCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            photoCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            
        ])
    }
    
    
    // MARK: ✅ setupAddPhotoButtonUI - 버튼을 생성하는 함수
    private func setupAddPhotoButtonUI() {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .black
        config.background.backgroundColor = .softMint
        config.cornerStyle = .medium
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        config.image = UIImage(systemName: "photo.badge.plus", withConfiguration: symbolConfig)
        config.imagePlacement = .top
        config.imagePadding = 8
        config.titleAlignment = .center
        
        addPhotoButton.configuration = config
    }
    
    
    // MARK: ✅ Update only subtitle - 버튼 내에 (선택 사진 수 / 최대 선택 가능한 사진 수)
    private func updateAddPhotoCount() {
        var config = addPhotoButton.configuration ?? UIButton.Configuration.plain()
        config.subtitle = "(\(images.count)/\(maxImageCount))"
        addPhotoButton.configuration = config
    }

    
    // MARK: ✅ Public Methods
    func updateImages(_ images: [UIImage]) {
        self.images = images
        DispatchQueue.main.async {
            self.refresh()
        }
    }
    
    func appendImage(_ image: UIImage) {
        guard images.count < maxImageCount else { return }
        images.append(image)
        DispatchQueue.main.async {
            self.refresh()
        }
    }
    
    func removeImage(at index: Int) {
        guard index < images.count else { return }
        images.remove(at: index)
        DispatchQueue.main.async {
            self.refresh()
        }
    }
    
    func getImages() -> [UIImage] {
        return images
    }
    
    private func refresh() {
        photoCollectionView.reloadData()
        updateAddPhotoCount()
        onImagesUpdated?(images)
    }
    
    // MARK: ✅ Action Method - Button Tapped
    @objc private func addPhotoTapped() {
        onAddPhotoTapped?()
    }
    
}


// MARK: ✅ Extension - UICollectionViewDelegate, UICollectionViewDataSource
extension DiaryPhotoGalleryCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoItemCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoItemCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(image: images[indexPath.item])
        
        cell.onRemove = { [weak self] in
            guard let self else { return }
            self.removeImage(at: indexPath.item)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onPreviewRequested?(images, indexPath.item)
    }
    
}
