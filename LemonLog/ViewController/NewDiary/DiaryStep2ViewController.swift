//
//  DiaryStep2ViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/12/25.
//

import UIKit

class DiaryStep2ViewController: UIViewController {
    
    
    // MARK: ✅ Closure
    var onNext: ((String, String) -> Void)?
    var onBack: (() -> Void)?
    
    
    // MARK: ✅ Step Info
    var currentStep: Float = 2.0
    var totalSteps: Float = 3.0
    
    
    // MARK: ✅ UI
    private let headerView = ProgressHeaderView()
    private let titleLabel = UILabel()
    private let guideLabel = UILabel()
    private let emotionTextView = UITextView()
    private let thoughtTextView = UITextView()
    private let placeholderLabel: UILabel = UILabel()
    private let nextButton = UIButton(type: .system)

    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .sageGreen
        
        titleLabel.text = "💖 감정 & 🤔 생각"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        guideLabel.text = "그때 어떤 감정을 느꼈고, 왜 그런 감정을 느꼈는지 적어보세요."
        guideLabel.font = .systemFont(ofSize: 16)
        guideLabel.textColor = .systemGray
        guideLabel.numberOfLines = 0
        
        [emotionTextView, thoughtTextView].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.textColor = .black
            $0.delegate = self
        }
        
        placeholderLabel.text = "예: 나는 중요한 순간에 실수를 하는 사람이라고 느꼈다."
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = .placeholderText
        
        nextButton.setTitle("다음으로", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        nextButton.tintColor = .white
        nextButton.backgroundColor = .systemGreen
        nextButton.layer.cornerRadius = 12
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        [headerView, titleLabel, guideLabel, emotionTextView, thoughtTextView, placeholderLabel, nextButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            guideLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            guideLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            guideLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emotionTextView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 16),
            emotionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emotionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emotionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            thoughtTextView.topAnchor.constraint(equalTo: emotionTextView.bottomAnchor, constant: 12),
            thoughtTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            thoughtTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            thoughtTextView.heightAnchor.constraint(equalToConstant: 120),
            
            placeholderLabel.leadingAnchor.constraint(equalTo: thoughtTextView.leadingAnchor, constant: 8),
            placeholderLabel.topAnchor.constraint(equalTo: thoughtTextView.topAnchor, constant: 8),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    
    // MARK: ✅ Setup Bindings
    private func setupBindings() {
        headerView.configure(
            current: currentStep,
            totalSteps: totalSteps,
            title: "💖 감정 & 🤔 생각",
            showBackButton: true
        )
        headerView.onBackButtonTapped = { [weak self] in self?.onBack?() }
    }
    
    
    // MARK: ✅ Action Method
    @objc private func nextButtonTapped() {
        onNext?(emotionTextView.text, thoughtTextView.text)
    }
    
}


// MARK: ✅ Extension - UITextViewDelegate
extension DiaryStep2ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}
