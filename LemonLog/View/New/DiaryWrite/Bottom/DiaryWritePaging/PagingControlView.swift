//
//  PagingControlView.swift
//  LemonLog
//
//  Created by 권정근 on 12/6/25.
//
// ▶️ Prev, Next Button + PagingIndicator 관리하는 뷰 ◀️


import UIKit

final class PagingControlView: UIView {
    
    
    // MARK: ✅ UI
    private let prevButton: UIButton = UIButton(type: .system)
    private let nextButton: UIButton = UIButton(type: .system)
    private let indicator: PagingIndicator
    
    private let doneButton: UIButton = UIButton(type: .system)
    
    
    // MARK: ✅ Data
    private var total: Int = 0
    
    var current: Int = 0 {
        didSet {
            updateUI()
        }
    }
    
    private var isFirstPage: Bool { current == 0 }
    private var isLastPage: Bool { current == total - 1 }
    
    
    // MARK: ✅ Callbacks
    var onTapPrev: (() -> Void)?
    var onTapNext: (() -> Void)?
    var onTapDone: (() -> Void)?
    
    
    // MARK: ✅ Initialization
    init(total: Int) {
        self.total = total
        self.indicator = PagingIndicator(total: total)
        super.init(frame: .zero)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Setup UI
    private func setupUI() {
        backgroundColor = .clear
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        
        // Prev Button
        prevButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        prevButton.tintColor = .darkGray
        prevButton.backgroundColor = UIColor(white: 0.95, alpha: 1)
        prevButton.layer.cornerRadius = 28
        prevButton.addTarget(self, action: #selector(didTapPrev), for: .touchUpInside)
        
        // Next Button
        nextButton.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        nextButton.tintColor = .white
        nextButton.backgroundColor = UIColor.systemPurple
        nextButton.layer.cornerRadius = 28
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        
        doneButton.setImage(UIImage(systemName: "checkmark", withConfiguration: config), for: .normal)
        doneButton.tintColor = .white
        doneButton.backgroundColor = UIColor.systemPurple
        doneButton.layer.cornerRadius = 28
        doneButton.isHidden = true
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(prevButton)
        addSubview(indicator)
        addSubview(nextButton)
        addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            prevButton.widthAnchor.constraint(equalToConstant: 56),
            prevButton.heightAnchor.constraint(equalToConstant: 56),
            prevButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            prevButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            nextButton.widthAnchor.constraint(equalToConstant: 56),
            nextButton.heightAnchor.constraint(equalToConstant: 56),
            nextButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            nextButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            doneButton.widthAnchor.constraint(equalToConstant: 56),
            doneButton.heightAnchor.constraint(equalToConstant: 56),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            doneButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    
    // MARK: ✅ Update
    private func updateUI() {
        indicator.update(current: current)
        
        // 첫 페이지: prev 버튼 숨김
        prevButton.isHidden = isFirstPage
        
        // 마지막 페이지: next 버튼 숨김
        nextButton.isHidden = isLastPage
        
        doneButton.isHidden = !isLastPage
    
    }
    
    
    // MARK: ✅ Actions Method
    @objc private func didTapPrev() {
        onTapPrev?()
    }

    @objc private func didTapNext() {
        onTapNext?()
    }
    
    @objc private func didTapDone() {
        onTapDone?()
    }
    
}
