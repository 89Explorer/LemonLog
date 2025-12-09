//
//  StepProgressView.swift
//  LemonLog
//
//  Created by 권정근 on 12/6/25.
//
// ▶️ label, progressview를 통해 단계 표시하는 뷰 ◀️


import UIKit


final class StepProgressView: UIView {

    
    // MARK: ✅ UI
    private let stepLabel: UILabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    
    // MARK: ✅ Data
    private(set) var current: Int = 0
    private(set) var total: Int = 1
    
    
    // MARK: ✅ Initialization
    init(total: Int) {
        self.total = total
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        update(current: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Setup UI
    private func setupUI() {
        backgroundColor = .clear
        
        // Step Label
        stepLabel.font = UIFont(name: "DungGeunMo", size: 24)
        stepLabel.textColor = .darkGray
        stepLabel.textAlignment = .center
        
        // Progress View
        progressView.trackTintColor = UIColor.systemGray5
        progressView.progressTintColor = UIColor.systemPurple
        progressView.layer.cornerRadius = 1.5
        progressView.clipsToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [stepLabel, progressView])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
        
    }
    
    
    // MARK: ✅ Update UI
    func update(current: Int) {
        self.current = current
        
        stepLabel.text = "\(current + 1)/\(total)"
        let progress = Float(current + 1) / Float(total)
        progressView.setProgress(progress, animated: true)
    }
}
