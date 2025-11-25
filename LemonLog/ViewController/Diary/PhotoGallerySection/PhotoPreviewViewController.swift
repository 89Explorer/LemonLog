//
//  PhotoPreviewViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/15/25.
//

import UIKit


final class PhotoPreviewViewController: UIViewController {
    
    
    // MARK: ✅ Properties
    private let images: [UIImage]
    private var startIndex: Int
    
    
    // MARK: ✅ UI
    private var collectionView: UICollectionView!
    private var pageLabel: UILabel!
    private var closeBtn: UIButton!
    
    
    // MARK: ✅ Init
    init(images: [UIImage], startIndex: Int) {
        self.images = images
        self.startIndex = startIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        scrollToStartIndex()
        updatePageLabel(index: startIndex)
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .systemBackground
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = UIScreen.main.bounds.size
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(PreviewImageCell.self, forCellWithReuseIdentifier: PreviewImageCell.reuseIdentifier)
        
        pageLabel = UILabel()
        pageLabel.font = .systemFont(ofSize: 20, weight: .bold)
        pageLabel.textColor = .systemBlue
        pageLabel.textAlignment = .center
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let closeImage = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        
        closeBtn = UIButton(type: .system)
        closeBtn.setImage(closeImage, for: .normal)
        closeBtn.tintColor = .systemBlue
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        view.addSubview(collectionView)
        view.addSubview(pageLabel)
        view.addSubview(closeBtn)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeBtn.widthAnchor.constraint(equalToConstant: 32),
            closeBtn.heightAnchor.constraint(equalToConstant: 32)
        ])
        
    }
    
    
    // MARK: ✅ scrollToStartIndex - 이미지 스크롤 함수
    private func scrollToStartIndex() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(item: self.startIndex, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    
    // MARK: ✅ updatePageLabel - 인데스 표기
    private func updatePageLabel(index: Int) {
        pageLabel.text = "\(index + 1) / \(images.count)"
    }
    
    
    // MARK: ✅ Action Method
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}


// MARK: ✅ UICollectionViewDelegate, UICollectionViewDataSource
extension PhotoPreviewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PreviewImageCell.reuseIdentifier, for: indexPath) as? PreviewImageCell else { return UICollectionViewCell() }
        
        cell.configure(with: images[indexPath.item])
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.frame.width)
        updatePageLabel(index: index)
    }
    
}
