//
//  PreviewImageCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/15/25.
//

import UIKit


final class PreviewImageCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "PreviewImageCell"
    
    
    // MARK: ✅ UI
    private var scrollView: UIScrollView = UIScrollView()
    private var imageView: UIImageView = UIImageView()
    
    
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
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.delegate = self
        scrollView.frame = contentView.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame = scrollView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        scrollView.addSubview(imageView)
        contentView.addSubview(scrollView)
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
    }
}


// MARK: ✅ UIScrollViewDelegate
extension PreviewImageCell: UIScrollViewDelegate {
   
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}
