//
//  SaveButtonCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/16/25.
//

import UIKit

class SaveButtonCell: UICollectionViewCell {
    
    
    // MARK: ✅ Static
    static let reuseIdentifier: String = "SaveButtonCell"
    
    
    // MARK: ✅ Closure
    var onTapSave: (() -> Void)?
    
    
    // MARK: ✅ UI
    private var saveButton: UIButton = UIButton(type: .system)
    
    
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
        contentView.backgroundColor = .clear
        
        saveButton.setTitle(NSLocalizedString("save_button_title", comment: ""), for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        saveButton.backgroundColor = .pastelLemon
        saveButton.layer.cornerRadius = 12
        saveButton.setTitleColor(.label, for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    
    // MARK: ✅ Action Method
    @objc private func didTapButton() {
        onTapSave?()
    }
    
}
