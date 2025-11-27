//
//  ToastMessage.swift
//  LemonLog
//
//  Created by 권정근 on 11/26/25.
//

import Foundation
import UIKit


// MARK: ✅ Class - 토스트 메시지 매니저
final class ToastManager {
    
    static func show(_ type: ToastType,
                     position: ToastPosition = .bottom) {
        let toast = ToastView(type: type)
        toast.present(position: position)
    }
    
}


// MARK: ✅ Enum - 토스트 메시지 보이는 위치 설정
enum ToastPosition {
    case top
    case center
    case bottom
}


// MARK: ✅ Enum - 토스트 메시지 구분 (아이콘 + 메시지 + 색상)
enum ToastType {
    case saved
    case updated
    case deleted
    
    var icon: String {
        switch self {
        case .saved: return "💾"
        case .updated: return "✏️"
        case .deleted: return "🗑️"
        }
    }
    
    var message: String {
        switch self {
        case .saved:
            return NSLocalizedString("toast.saved", comment: "")
        case .updated:
            return NSLocalizedString("toast.updated", comment: "")
        case .deleted:
            return NSLocalizedString("toast.deleted", comment: "")
        }
    }
    
    // 배경색 또는 강조 색상
    var backgroundColor: UIColor {
        switch self {
        case .saved:
            return UIColor.systemGreen.withAlphaComponent(0.9)
        case .updated:
            return UIColor.systemBlue.withAlphaComponent(0.9)
        case .deleted:
            return UIColor.systemRed.withAlphaComponent(0.9)
        }
    }
}


// MARK: ✅ Class - 토스트 뷰
final class ToastView: UIView {
    
    private let messageLabel = UILabel()
    private var hideWorkItem: DispatchWorkItem?
    
    
    init(type: ToastType) {
        super.init(frame: .zero)
        setupUI(type)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI(_ type: ToastType) {
        
        backgroundColor = type.backgroundColor
        layer.cornerRadius = 12
        alpha = 0
        
        messageLabel.text = "\(type.icon)  \(type.message)"
        messageLabel.textColor = .white
        messageLabel.font = .boldSystemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    
    func present(position: ToastPosition) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }
        
        window.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
        let verticalConstraint: NSLayoutConstraint
        
        switch position {
        case .top:
            verticalConstraint = topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 20)
        case .center:
            verticalConstraint = centerYAnchor.constraint(equalTo: window.centerYAnchor)
        case .bottom:
            verticalConstraint = bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        }
        
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: window.centerXAnchor),
            widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, multiplier: 0.85),
            verticalConstraint
        ])
        
        // 🔥 햅틱
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        window.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
    
    
    // 🔻 이게 없어서 에러 났던 부분!
    private func dismiss() {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

