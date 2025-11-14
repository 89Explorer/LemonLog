//
//  DiaryAccessoryView.swift
//  LemonLog
//
//  Created by 권정근 on 11/14/25.
//

import UIKit


final class DiaryAccessoryView: UIView {

    
    // MARK: ✅ Closure
    var onKeyboardDismiss: (() -> Void)?
    

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
        backgroundColor = UIColor.systemGray6
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray3.cgColor
        
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // inputAccessoryView에서는 intrinsicContentSize가 제대로 반영되지 않는 경우가 많음
            self.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let hideKeyboard = makeButton("keyboard.chevron.compact.down.fill", action: #selector(tapDismiss))
        hideKeyboard.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hideKeyboard)
        
        NSLayoutConstraint.activate([
            hideKeyboard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            hideKeyboard.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            hideKeyboard.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    
    // MARK: ✅ Make Button
    func makeButton(_ title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        btn.setImage(UIImage(systemName: title, withConfiguration: config), for: .normal)
        btn.tintColor = .black 
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    

    // MARK: ✅ Action Methods
    @objc private func tapDismiss() { onKeyboardDismiss?() }

}



// --------------------------------------------------------------------------------------------------------
// MARK: - 🔒 Text Formatting (차후 활성화 예정)
// 글 서식 데이터를 저장하는 구조 개선 후 적용
/*
final class DiaryAccessoryView: UIView {

    
    // MARK: ✅ Closure
    var onIncreaseFont: (() -> Void)?
    var onDecreaseFont: (() -> Void)?
    var onAlignLeft: (() -> Void)?
    var onAlignCenter: (() -> Void)?
    var onAlignRight: (() -> Void)?
    var onColorTap: ((UIView) -> Void)?   // popover anchor
    var onKeyboardDismiss: (() -> Void)?
    
    
    // MARK: ✅ UI
    private var colorBtn: UIButton!
    
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
        backgroundColor = UIColor.systemGray6
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray3.cgColor
        
        let increaseBtn = makeButton("textformat.size.larger", action: #selector(tapIncrease))
        let decreaseBtn = makeButton("textformat.size.smaller", action: #selector(tapDecrease))
        let leftBtn = makeButton("text.alignleft", action: #selector(tapAlignLeft))
        let centerBtn = makeButton("text.aligncenter", action: #selector(tapAlignCenter))
        let rightBtn = makeButton("text.alignright", action: #selector(tapAlignRight))
        
        colorBtn = makeButton("paintpalette", action: #selector(tapColor))
        
        let hideKeyboard = makeButton("keyboard.chevron.compact.down.fill", action: #selector(tapDismiss))
        
        let stack = UIStackView()
        [increaseBtn, decreaseBtn, leftBtn, centerBtn, rightBtn, colorBtn, hideKeyboard].forEach { stack.addArrangedSubview($0)
        }
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    
    // MARK: ✅ Make Button
    func makeButton(_ title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        btn.setImage(UIImage(systemName: title, withConfiguration: config), for: .normal)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }
    
    
    
    // MARK: ✅ Action Methods
    @objc private func tapIncrease() { onIncreaseFont?() }
    @objc private func tapDecrease() { onDecreaseFont?() }
    @objc private func tapAlignLeft() { onAlignLeft?() }
    @objc private func tapAlignCenter() { onAlignCenter?() }
    @objc private func tapAlignRight() { onAlignRight?() }
    
    @objc private func tapColor() {
        onColorTap?(colorBtn)     // colorButton → popover anchor용
    }
    
    @objc private func tapDismiss() { onKeyboardDismiss?() }

}
*/
