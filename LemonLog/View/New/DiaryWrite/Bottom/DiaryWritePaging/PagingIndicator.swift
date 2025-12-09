//
//  PagingIndicator.swift
//  LemonLog
//
//  Created by 권정근 on 12/6/25.
//
// ▶️ PagingIndicator는 “현재 단계 표시” 역할을 맡고 있음 ◀️


import UIKit


final class PagingIndicator: UIView {
    
    
    // MARK: ✅ UI
    private let stackView: UIStackView = UIStackView()
    private var dots: [UIView] = []
    
    
    // MARK: ✅ Data
    private var total: Int = 0
    
    // dot의 가로폭 길이 저장
    private var dotWidthConstraints: [NSLayoutConstraint] = []
    
    
    // MARK: ✅ Initialization
    init(total: Int) {
        super.init(frame: .zero)
        self.total = total
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: ✅ Setup UI
    private func setupUI() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        
        for _ in 0..<total {
            let dot = UIView()
            dot.backgroundColor = .lightGray
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            
            let widthConstraint = dot.widthAnchor.constraint(equalToConstant: 8)
            widthConstraint.isActive = true
            
            NSLayoutConstraint.activate([
                dot.heightAnchor.constraint(equalToConstant: 8)
            ])
            
            dotWidthConstraints.append(widthConstraint)
            dots.append(dot)
            stackView.addArrangedSubview(dot)
        }
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    
    // MARK: ✅ update
    // 현재 페이지에 해당하는 dot을 변경하는 함수
    func update(current: Int) {
        
        // 애니메이션 효과 적용 (전체 동작이 0.25초 동안 Ease - in - out으로 적용)
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.25,
            options: [.curveEaseInOut, .allowUserInteraction]
        ) {
            for (i, dot) in self.dots.enumerated() {
                
                let isActive = (i == current)
                
                dot.backgroundColor = isActive ? UIColor.systemPurple : UIColor.systemGray4
                dot.alpha = isActive ? 1.0 : 0.5
                
                // width 변경
                self.dotWidthConstraints[i].constant = isActive ? 22 : 8
                
                // 코너 라운드 업데이트
                dot.layer.cornerRadius = isActive ? 4 : 4 // 같지만 pill이 되려면 height/2
                
                dot.layoutIfNeeded()  // 애니메이션 적용
            }
            
        }
    }
    
}
