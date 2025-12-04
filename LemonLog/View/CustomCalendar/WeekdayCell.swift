//
//  WeekdayCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/28/25.
//

import UIKit

class WeekdayCell: UICollectionViewCell {
    
    
    // MARK: Static
    static let reuseIdentifier: String = "WeekDayCell"
    
    
    // MARK: UI
    private let label: UILabel = UILabel()

    
    // MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ConfigureUI
    private func configureUI() {
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    
    // MARK: Configure Data
    func configure(text: String, isSunday: Bool, isSaturday: Bool) {
        label.text = text
        
        if isSunday {
            label.textColor = .systemRed
        } else  if isSaturday {
            label.textColor = .systemBlue
        } else {
            label.textColor = .black
        }
    }
    
}
