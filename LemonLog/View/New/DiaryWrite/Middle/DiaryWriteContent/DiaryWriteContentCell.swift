//
//  DiaryWriteContentCell.swift
//  LemonLog
//
//  Created by 권정근 on 12/9/25.
//
// ▶️ 감정일기에서 내용에 작성하는 할 수 있는 셀 ◀️

import UIKit


final class DiaryWriteContentCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "DiaryWriteContentCell"
    
    
    // MARK: ✅ Callbacks
    var textChanged: ((String) -> Void)?
    var didBeginEditing: (() -> Void)?
    
    
    // MARK: ✅ Constants
    private let maxCharacters: Int = 300
    
    
    // MARK: ✅ UI
    private let titleLabel = UILabel()
    private let guideLabel = UILabel()
    private let textView = UITextView()
    private let placeholderLabel1 = UILabel()
    private let placeholderLabel2 = UILabel()
    private let counterLabel = UILabel()
    private let errorLabel = UILabel()
    
    
    // MARK: ✅ AccessoryView (키보드 내리는 뷰)
    private lazy var accessory: DiaryAccessoryView = {
        let view = DiaryAccessoryView()
        view.onKeyboardDismiss = { [weak self] in
            self?.textView.resignFirstResponder()
        }
        return view
    }()
    
    
    // MARK: ✅ Init (⭐️ 컬렉션뷰가 호출하는 이 생성자 필수)
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()   // 여기서는 레이아웃/스타일만 세팅
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Public (외부에서 내용 세팅)
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
    
    // setText
    func setText(_ text: String) {
        textView.text = text
        updatePlaceholder()
        updateCounter()
        clearError()
    }
    
    // showError
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        textView.layer.borderColor = UIColor.systemRed.cgColor
    }
    
    // clearError
    func clearError() {
        errorLabel.isHidden = true
        textView.layer.borderColor = UIColor.systemGray5.cgColor
    }
}


// MARK: ✅ Configure UI
private extension DiaryWriteContentCell {
    
    func configureUI() {
        setupLabels()
        setupTextView()
        setupLayout()
    }
    
    func setupLabels() {
        // Title
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "DungGeunMo", size: 20)
        titleLabel.textAlignment = .center
        
        // Guide
        guideLabel.textColor = .darkGray
        guideLabel.font = UIFont(name: "DungGeunMo", size: 12)
        guideLabel.numberOfLines = 0
        guideLabel.textAlignment = .center
        
        // Placeholder
        [placeholderLabel1, placeholderLabel2].forEach {
            $0.textColor = .placeholderText
            $0.font = UIFont(name: "DungGeunMo", size: 12)
            $0.numberOfLines = 0
        }
        
        // Counter
        counterLabel.text = "0 / \(maxCharacters)"
        counterLabel.font = UIFont(name: "DungGeunMo", size: 12)
        counterLabel.textColor = .lightGray
        
        // Error
        errorLabel.font = UIFont(name: "DungGeunMo", size: 12)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true
    }
    
    func setupTextView() {
        textView.delegate = self
        textView.textColor = .black
        textView.font = UIFont(name: "DungGeunMo", size: 12)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.systemGray5.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.inputAccessoryView = accessory
        textView.isScrollEnabled = false
    }
    
    func setupLayout() {
        [titleLabel, guideLabel, textView, counterLabel, errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        contentView.addSubview(placeholderLabel1)
        contentView.addSubview(placeholderLabel2)
        
        placeholderLabel1.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            guideLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            guideLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            textView.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            placeholderLabel1.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel1.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            placeholderLabel1.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            
            placeholderLabel2.topAnchor.constraint(equalTo: placeholderLabel1.bottomAnchor, constant: 8),
            placeholderLabel2.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 8),
            placeholderLabel2.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            
            counterLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            counterLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            //counterLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            errorLabel.bottomAnchor.constraint(equalTo: counterLabel.topAnchor, constant: -2),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            //errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}


// MARK: ✅ UITextViewDelegate
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
    
    // maxCharacters를 기준으로 글자수 제한하는 함수
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
