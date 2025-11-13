//
//  DiaryStep3ViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/12/25.
//

import UIKit

class DiaryStep3ViewController: UIViewController {
    
    
    // MARK: ✅ Closure
    var onComplete: ((String, String) -> Void)?
    var onBack: (() -> Void)?
    
    
    // MARK: ✅ Step Info
    var currentStep: Float = 3
    var totalSteps: Float = 3
    
    
    // MARK: ✅ UI
    private let headerView = ProgressHeaderView()
    private let titleLabel = UILabel()
    private let guideLabel = UILabel()
    private let reflectionTextView = UITextView()
    private let reflectionplaceholderLabel: UILabel = UILabel()
    private let planTextView = UITextView()
    private let planplaceholderLabel: UILabel = UILabel()
    private let completeButton = UIButton(type: .system)

    
    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .sageGreen
        
        titleLabel.text = "💡 새로운 시각 & ✅ 다음 행동"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        guideLabel.text = "이 경험을 다르게 볼 수 있을까요?\n다음에 비슷한 상황이 생긴다면 어떻게 해볼까요?"
        guideLabel.font = .systemFont(ofSize: 16)
        guideLabel.textColor = .systemGray
        guideLabel.numberOfLines = 0
        
        [reflectionTextView, planTextView].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.layer.cornerRadius = 8
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.textColor = .black
            $0.delegate = self
        }
        
        reflectionplaceholderLabel.text = "예: 실수를 했지만 준비는 충분했고, 성장의 기회였다."
        reflectionplaceholderLabel.textColor = .placeholderText
        planplaceholderLabel.text = "예: 다음 발표 전 3회 연습하기, 발표 중 긴장되면 심호흡 3초 하기."
        planplaceholderLabel.textColor = .placeholderText
        
        completeButton.setTitle("작성 완료", for: .normal)
        completeButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        completeButton.tintColor = .white
        completeButton.backgroundColor = .systemGreen
        completeButton.layer.cornerRadius = 12
        completeButton.addTarget(self, action: #selector(completeTapped), for: .touchUpInside)
        
        [headerView, titleLabel, guideLabel, reflectionTextView, planTextView, completeButton].forEach {
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
            
            reflectionTextView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            reflectionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            reflectionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            reflectionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            reflectionplaceholderLabel.leadingAnchor.constraint(equalTo: reflectionTextView.leadingAnchor, constant: 8),
            reflectionplaceholderLabel.topAnchor.constraint(equalTo: reflectionTextView.topAnchor, constant: 8),
            
            planTextView.topAnchor.constraint(equalTo: reflectionTextView.bottomAnchor, constant: 12),
            planTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            planTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            planTextView.heightAnchor.constraint(equalToConstant: 120),
            
            planplaceholderLabel.leadingAnchor.constraint(equalTo: planTextView.leadingAnchor, constant: 8),
            planplaceholderLabel.topAnchor.constraint(equalTo: planTextView.topAnchor, constant: 8),
            
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    
    // MARK: ✅ Setup Bindings
    private func setupBindings() {
        headerView.configure(
            current: currentStep,
            totalSteps: totalSteps,
            title: "💡 새로운 시각 & ✅ 다음 행동",
            showBackButton: true
        )
        headerView.onBackButtonTapped = { [weak self] in self?.onBack?() }
    }
    
    
    // MARK: ✅ Action Method
    @objc private func completeTapped() {
        onComplete?(reflectionTextView.text, planTextView.text)
    }
    
}


// MARK: ✅ Extension - UITextViewDelegate
extension DiaryStep3ViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == reflectionTextView {
            reflectionplaceholderLabel.isHidden = !textView.text.isEmpty
        } else if textView == planTextView {
            planplaceholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
}
