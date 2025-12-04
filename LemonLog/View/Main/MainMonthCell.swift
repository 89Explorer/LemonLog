//
//  MainMonthCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/28/25.
//

import UIKit


final class MainMonthCell: UICollectionViewCell {
    
    
    // MARK: ▶️ Reuse Identifier
    static let reuseIdentifier: String = "MainMonthCell"
    

    // MARK: ▶️ MonthLabel
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.text = "11월"
        label.textColor = .label
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .regular)
        return label
    }()

    
    // MARK: ▶️ Buttons
    private lazy var prevButton: UIButton = createButton(
        systemName: "arrowtriangle.left.fill",
        action: #selector(didTapPrevButton)
    )
    
    private lazy var nextButton: UIButton = createButton(
        systemName: "arrowtriangle.right.fill",
        action: #selector(didTapNextButton)
    )
    
    // MARK: ▶️ Month StackView
    private lazy var monthStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [prevButton, monthLabel, nextButton])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .equalCentering
        sv.spacing = 4
        return sv
    }()
    
    
    // MARK: ▶️ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: ▶️ UI Setup
    private func setupUI() {
        contentView.backgroundColor = .softMint
        contentView.layer.cornerRadius = 28
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        contentView.clipsToBounds = true 
        contentView.addSubview(monthStackView)
        monthStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            monthStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            monthStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            monthStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}



// MARK: ▶️ Extension - Helper(버튼 생성 함수) & Actions
extension MainMonthCell {
    
    
    // 버튼 생성 함수
    private func createButton(systemName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        button.setImage(UIImage(systemName: systemName, withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    
    @objc private func didTapPrevButton() {
        print("PrevButton called")
    }
    
    
    @objc private func didTapNextButton() {
        print("NextButton called")
    }
}


// MARK: ▶️ Extension - Configure Data
extension MainMonthCell {
    
    func configure(with month: String) {
        monthLabel.text = month
    }
}
