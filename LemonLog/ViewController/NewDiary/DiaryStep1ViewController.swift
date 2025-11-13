//
//  DiaryStep1ViewController.swift
//  LemonLog
//
//  Created by 권정근 on 11/12/25.
//

import UIKit

class DiaryStep1ViewController: UIViewController {
    
    
    // MARK: ✅ Closure
    var onNext: ((String) -> Void)?
    var onBack: (() -> Void)?
    
    
    // MARK: ✅ Step Info
    var currentStep: Float = 1
    var totalSteps: Float = 3
    
    
    // MARKK: ✅ UI
    private let headerView: ProgressHeaderView = ProgressHeaderView()
    private let titleLabel: UILabel = UILabel()
    private let guideLabel: UILabel = UILabel()
    private let textView: UITextView = UITextView()
    private let placeholderLabel: UILabel = UILabel()
    private let nextButton: UIButton = UIButton(type: .system)
    

    // MARK: ✅ Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupBindings()
    }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        view.backgroundColor = .sageGreen
        
        titleLabel.text = "📍 상황"
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        guideLabel.text = "무슨 일이 일어났나요?\n 객관적인 사실만 기록 (시간, 장소, 관련된 사람 등)"
        guideLabel.font = .systemFont(ofSize: 16)
        guideLabel.textColor = .systemGray
        guideLabel.numberOfLines = 0
        
        textView.font = .systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.delegate = self
        textView.isScrollEnabled = false
        
        placeholderLabel.text = "누가, 언제, 어디서, 무엇을 했는지, 제3자가 보아도 명확하게 알 수 있도록 사실만 적어주세요. (예: 오늘 오후 3시, 팀 회의에서 발표를 마쳤다.)"
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = .placeholderText
        
        nextButton.setTitle("다음으로", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        nextButton.tintColor = .white
        nextButton.backgroundColor = .systemGreen
        nextButton.layer.cornerRadius = 12
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        [headerView, titleLabel, guideLabel, textView, placeholderLabel, nextButton].forEach {
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
            
            textView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            
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
            title: "📍 상황 작성",
            showBackButton: currentStep > 1
        )
        headerView.onBackButtonTapped = { [weak self] in self?.onBack?() }
    }
    
    
    // MARK: ✅ Action Method
    @objc private func nextButtonTapped() {
        guard let text = textView.text, !text.isEmpty else { return }
        onNext?(text)
    }
}


// MARK: ✅ Extension - UITextViewDelegate
extension DiaryStep1ViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
}
