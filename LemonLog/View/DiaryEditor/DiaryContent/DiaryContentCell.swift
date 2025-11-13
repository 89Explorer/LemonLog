//
//  DiaryContentCell.swift
//  LemonLog
//
//  Created by 권정근 on 11/13/25.
//

import UIKit


final class DiaryContentCell: UICollectionViewCell {
    
    
    // MARK: ✅ ReuseIdentifier
    static let reuseIdentifier: String = "DiaryContentCell"
    
    
    // MARK: ✅ Closure
    var onContentChanged: ((String) -> Void)?
    var onFocusChanged: ((UIView) -> Void)?    // 상위로 전달
    
    
    // MARK: ✅ UI
    private let stackView: UIStackView = UIStackView()
    
    private let situationSection = DiaryContentView(
        titleKey: "diary.situation.title",
        guideKey: "diary.situation.guide",
        placeholderKey1: "diary.situation.placeholder1",
        placeholderKey2: "diary.situation.placeholder2"
    )
    
    private let thoughtSection = DiaryContentView(
        titleKey: "diary.thought.title",
        guideKey: "diary.thought.guide",
        placeholderKey1: "diary.thought.placeholder1",
        placeholderKey2: "diary.thought.placeholder2"
    )
    
    private let reevalSection = DiaryContentView(
        titleKey: "diary.reeval.title",
        guideKey: "diary.reeval.guide",
        placeholderKey1: "diary.reeval.placeholder1",
        placeholderKey2: "diary.reeval.placeholder2"
    )
    
    private let actionSection = DiaryContentView(
        titleKey: "diary.action.title",
        guideKey: "diary.action.guide",
        placeholderKey1: "diary.action.placeholder1",
        placeholderKey2: "diary.action.placeholder2"
    )
    
    
    // MARK: ✅ Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        bindSections()
        addTapGestureForKeyboardDismiss()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    
    // MARK: ✅ Configure UI
    private func configureUI() {
        contentView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .fill

        
        [situationSection, thoughtSection, reevalSection, actionSection].forEach {
            stackView.addArrangedSubview($0)
        }
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        
    }
    
    
    // MARK: ✅ Setup Bindings
    private func bindSections() {
        let allSections = [situationSection, thoughtSection, reevalSection, actionSection]
        for section in allSections {
            
            section.textChanged = { [weak self] _ in
                self?.emitCombinedText()
            }
            
            section.onFocusChanged = { [weak self] view in
                self?.onFocusChanged?(view)
            }
            
        }
    }
    
    
    // MARK: ✅ emitCombinedText - 텍스트 통합
    private func emitCombinedText() {
        let combined = """
        [상황]
        \(situationSection.text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        [생각 / 원인]
        \(thoughtSection.text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        [새로운 시각 / 반박]
        \(reevalSection.text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        [다음 행동]
        \(actionSection.text.trimmingCharacters(in: .whitespacesAndNewlines))
        """
        
        onContentChanged?(combined)
    }
    
    
    // MARK: ✅ addTapGestureForKeyboardDismiss - 키보드 내리기
    private func addTapGestureForKeyboardDismiss() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: ✅ Action Method - dismissKeyboard
    @objc private func dismissKeyboard() {
        contentView.endEditing(true)
    }
}
