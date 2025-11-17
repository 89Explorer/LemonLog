//
//  DiaryContentView.swift
//  LemonLog
//
//  Created by 권정근 on 11/13/25.
//

import UIKit


final class DiaryContentView: UIView {

    
    // MARK: ✅ Closure
    var textChanged: ((String) -> Void)?
    var onFocusChanged: ((UIView) -> Void)?    // 편집 시작 알림
    
    
    // MARK: ✅ Property
    var text: String { textView.text }
    
    // 고정 높이를 위한 constraint
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    // 글자수 제한
    private let maxCharacters: Int = 300
    
    
    // MARK: ✅ UI
    private let titleLabel: UILabel = UILabel()
    private let guideLabel: UILabel = UILabel()
    private let textView: UITextView = UITextView()
    private let placeholderLabel1: UILabel = UILabel()
    private let placeholderLabel2: UILabel = UILabel()
    private let counterLabel: UILabel = UILabel()
    private let errorLabel: UILabel = UILabel()
    
    // Accessory - 키보드 내리기
    private lazy var accessory: DiaryAccessoryView = {
        let view = DiaryAccessoryView()
        view.onKeyboardDismiss = { [weak self] in
            self?.textView.resignFirstResponder()
        }
        return view
    }()
    
    
    // MARK: ✅ Init
    init(titleKey: String, guideKey: String, placeholderKey1: String, placeholderKey2: String) {
        super.init(frame: .zero)
        configureUI(
            titleKey: titleKey,
            guideKey: guideKey,
            placeholderKey1: placeholderKey1,
            placeholderKey2: placeholderKey2
        )
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    // MARK: ✅ Configure UI
    private func configureUI(
        titleKey: String,
        guideKey: String,
        placeholderKey1: String,
        placeholderKey2: String
    ) {
        
        let titleText = NSLocalizedString(titleKey, comment: "")
        let guideText = NSLocalizedString(guideKey, comment: "")
        let placeholderText1 = NSLocalizedString(placeholderKey1, comment: "")
        let placehodlerText2 = NSLocalizedString(placeholderKey2, comment: "")
        
        // Title ------------------------------
        titleLabel.text = titleText
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.numberOfLines = 1
        
        // Guide ------------------------------
        guideLabel.text = guideText
        guideLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        guideLabel.textColor = .systemGray
        guideLabel.numberOfLines = 0
        
        // TextView ------------------------------
        textView.font = .systemFont(ofSize: 12)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.delegate = self
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        textView.inputAccessoryView = accessory    // 액세서리 적용
        
        // Placeholder ------------------------------
        placeholderLabel1.text = placeholderText1
        placeholderLabel2.text = placehodlerText2
        [placeholderLabel1, placeholderLabel2].forEach {
            $0.textColor = .placeholderText
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
        }

        // Counter ------------------------------
        counterLabel.text = "0 / \(maxCharacters)"
        counterLabel.font = .systemFont(ofSize: 12)
        counterLabel.textColor = .systemGray
        
        // Error -----------------------------------------
        errorLabel.textColor = .systemRed
        errorLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        errorLabel.isHidden = true
        
        [titleLabel, guideLabel, textView, placeholderLabel1, placeholderLabel2, counterLabel, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Guide
            guideLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            guideLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            guideLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // TextView
            textView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 160),
            
            // Placeholder 1
            placeholderLabel1.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel1.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            placeholderLabel1.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            
            // Placeholder 2
            placeholderLabel2.topAnchor.constraint(equalTo: placeholderLabel1.bottomAnchor, constant: 8),
            placeholderLabel2.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            placeholderLabel2.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            
            // Counter Label
            counterLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            counterLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            counterLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Error Label
            errorLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
            
        ])
    }
    
    
    // MARK: ✅ showError()
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        textView.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    
    // MARK: ✅ clearError()
    func clearError() {
        errorLabel.isHidden = true
        textView.layer.borderColor = UIColor.systemGray5.cgColor
    }

}


// MARK: ✅ UITextViewDelegate
extension DiaryContentView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholder()
        onFocusChanged?(self) // 편집 시작 시 알림
    }
    
    func textViewDidChange(_ textView: UITextView) {
        limitCharacters(textView)
        updatePlaceholder()
        updateCounter()
        
        clearError()
        
        textChanged?(textView.text)
    }
    
    private func updatePlaceholder() {
        let isEmpty = textView.text.isEmpty
        placeholderLabel1.isHidden = !isEmpty
        placeholderLabel2.isHidden = !isEmpty
    }
    
    private func limitCharacters(_ textView: UITextView) {
        if textView.text.count > maxCharacters {
            textView.text = String(textView.text.prefix(maxCharacters))
        }
    }
    
    private func updateCounter() {
        counterLabel.text = "\(textView.text.count) / \(maxCharacters)"
    }
}
