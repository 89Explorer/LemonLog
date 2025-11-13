//
//  ProgressHeaderView.swift
//  LemonLog
//
//  Created by 권정근 on 11/12/25.
//

import UIKit

class ProgressHeaderView: UIView {
    
    
    // MARK: ✅ Clousre
    var onBackButtonTapped: (() -> Void)?
    
    
    // MARK: ✅ State
    private var currentProgress: Float = 0.0
    
    
    // MARK: ✅ UI
    private let backButton: UIButton = UIButton(type: .system)
    private let progressView: UIProgressView = UIProgressView(progressViewStyle: .default)
    private let stepLabel: UILabel = UILabel()
    private let stageTitleLabel: UILabel = UILabel()
    
    
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
        backgroundColor = .clear
        
        // backButton
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .black
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // progress
        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = .systemGray
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        // stage number
        stepLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        stepLabel.textColor = .systemGray
        stepLabel.textAlignment = .center
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // stage title
        stageTitleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        stageTitleLabel.textColor = .black
        stageTitleLabel.textAlignment = .center
        stageTitleLabel.numberOfLines = 1
        stageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backButton)
        addSubview(progressView)
        addSubview(stepLabel)
        addSubview(stageTitleLabel)
        
        NSLayoutConstraint.activate([
            
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),
            
            progressView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            progressView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            
            stepLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            stepLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            
            stageTitleLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 4),
            stageTitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            stageTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
    }
    
    
    // MARK: ✅ Configure Data
    func configure(current step: Float, totalSteps: Float, title: String, showBackButton: Bool) {
        backButton.isHidden = !showBackButton
        animateProgress(to: step / totalSteps)
        stepLabel.text = "\(Int(step)) / \(Int(totalSteps))단계"
        stageTitleLabel.text = title
    }
    
    
    // MARK: ✅ Animation
    private func animateProgress(to newValue: Float) {
        UIView.animate(withDuration: 0.35, delay: 0, options: [.curveEaseInOut]) {
            self.progressView.setProgress(newValue, animated: true)
        }
        currentProgress = newValue
    }
    
    
    // MARK: ✅ Action Method
    @objc private func backButtonTapped() {
        onBackButtonTapped?()
    }
}
