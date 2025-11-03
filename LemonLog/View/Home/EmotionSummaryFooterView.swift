//
//  EmotionSummaryFooterView.swift
//  LemonLog
//
//  Created by 권정근 on 10/31/25.
//

import UIKit

final class EmotionSummaryFooterView: UICollectionReusableView {
    
    static let reuseIdentifier = "EmotionSummaryFooterView"
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with emotions: [EmotionCategory]) {
        if emotions.isEmpty {
            label.text = "이번 주에 선택된 감정이 아직 없어요 🙂"
        } else {
            let icons = emotions.map { "🟡 \($0.rawValue)" }.joined(separator: "  ")
            label.text = "이번 주에 많이 느낀 감정: \(icons)"
        }
    }
}

