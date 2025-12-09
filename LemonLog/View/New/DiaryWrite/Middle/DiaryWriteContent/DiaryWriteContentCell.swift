//
//  DiaryWriteContentCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/9/25.
//

import UIKit

final class DiaryWriteContentCell: UICollectionViewCell {
    
    
    // MARK: - ReuseIdentifier
    static let reuseIdentifier: String = "DiaryWriteContentCell"
    
    
    // MARK: - Callbacks
    var textChanged: ((String) -> Void)?
    var didBeginEditing: (() -> Void)?
    
    // MARK: - Constants
    private let maxCharacters: Int = 300
    
    // MARK: - UI
    private let titleLabel = UILabel()
    private let guideLabel = UILabel()
    private let textView = UITextView()
    private let placeholderLabel1 = UILabel()
    private let placeholderLabel2 = UILabel()
    private let counterLabel = UILabel()
    private let errorLabel = UILabel()
    
    // MARK: - AccessoryView
    private lazy var accessory: DiaryAccessoryView = {
        let view = DiaryAccessoryView()
        view.onKeyboardDismiss = { [weak self] in
            self?.textView.resignFirstResponder()
        }
        return view
    }()
    
    // MARK: - Init (⭐️ 컬렉션뷰가 호출하는 이 생성자 필수)
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()   // 여기서는 레이아웃/스타일만 세팅
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public: 외부에서 내용 세팅
    func configure(
        titleKey: String,
        guideKey: String,
        placeholderKey1: String,
        placeholderKey2: String,
        text: String
    ) {
        titleLabel.text = NSLocalizedString(titleKey, comment: "")
        guideLabel.text = NSLocalizedString(guideKey, comment: "")
        placeholderLabel1.text = NSLocalizedString(placeholderKey1, comment: "")
        placeholderLabel2.text = NSLocalizedString(placeholderKey2, comment: "")
        
        setText(text)
    }
    
    func setText(_ text: String) {
        textView.text = text
        updatePlaceholder()
        updateCounter()
        clearError()
    }
    
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        textView.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    func clearError() {
        errorLabel.isHidden = true
        textView.layer.borderColor = UIColor.systemGray5.cgColor
    }
}


// MARK: - Configure UI
private extension DiaryWriteContentCell {
    
    func configureUI() {
        setupLabels()
        setupTextView()
        setupLayout()
    }
    
    func setupLabels() {
        // Title
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        // Guide
        guideLabel.textColor = .systemGray
        guideLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        guideLabel.numberOfLines = 0
        
        // Placeholder
        [placeholderLabel1, placeholderLabel2].forEach {
            $0.textColor = .placeholderText
            $0.font = .systemFont(ofSize: 12)
            $0.numberOfLines = 0
        }
        
        // Counter
        counterLabel.text = "0 / \(maxCharacters)"
        counterLabel.font = .systemFont(ofSize: 12)
        counterLabel.textColor = .systemGray
        
        // Error
        errorLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }
    
    func setupTextView() {
        textView.delegate = self
        textView.font = .systemFont(ofSize: 12)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.inputAccessoryView = accessory
        
        // placeholder를 textView 안에 추가
        textView.addSubview(placeholderLabel1)
        textView.addSubview(placeholderLabel2)
        
        placeholderLabel1.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            placeholderLabel1.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel1.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            placeholderLabel1.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -12),
            
            placeholderLabel2.topAnchor.constraint(equalTo: placeholderLabel1.bottomAnchor, constant: 6),
            placeholderLabel2.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            placeholderLabel2.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -12)
        ])
    }
    
    func setupLayout() {
        [titleLabel, guideLabel, textView, counterLabel, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            guideLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            guideLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            guideLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            textView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.heightAnchor.constraint(equalToConstant: 160),
            
            counterLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            counterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            errorLabel.bottomAnchor.constraint(equalTo: counterLabel.topAnchor, constant: -2),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}


// MARK: - UITextViewDelegate
extension DiaryWriteContentCell: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        updatePlaceholder()
        didBeginEditing?()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholder()
        updateCounter()
        clearError()
        textChanged?(textView.text)
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard let current = textView.text,
              let stringRange = Range(range, in: current) else {
            return true
        }
        
        let newText = current.replacingCharacters(in: stringRange, with: text)
        return newText.count <= maxCharacters
    }
}


// MARK: - Helpers
private extension DiaryWriteContentCell {
    
    func updatePlaceholder() {
        let isEmpty = textView.text.isEmpty
        placeholderLabel1.isHidden = !isEmpty
        placeholderLabel2.isHidden = !isEmpty
    }
    
    func updateCounter() {
        counterLabel.text = "\(textView.text.count) / \(maxCharacters)"
    }
}
