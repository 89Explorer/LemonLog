//
//  MainGreenHeaderView.swift
//  LemonLog
//
//  Created by 권정근 on 11/29/25.
//

import UIKit

class MainGreenHeaderView: UICollectionReusableView {
    
    
    // MARK: ▶️ Reuse Identifier
    static let reuseIdentifier: String = "MainGreenHeaderView"
    
    
    // MARK: ▶️ UI - 백그라운드 뷰
    private let bgView: UIView = {
        let v = UIView()
        v.backgroundColor = .softMint
        v.layer.cornerRadius = 32
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // bottom only
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    
    // MARK: ▶️ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ▶️ Setup UI
    private func setupUI() {
        addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: topAnchor),
            bgView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
