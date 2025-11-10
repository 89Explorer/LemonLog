//
//  Extension.swift
//  LemonLog
//
//  Created by 권정근 on 11/4/25.
//

import Foundation
import UIKit


// MARK: ✅ Extension - 이미지 리사이즈 유틸
extension UIImage {
    
    func resized(to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let render = UIGraphicsImageRenderer(size: size, format: format)
        return render.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}


// MARK: ✅ Class - UILabel에 Padding 적용
class BasePaddingLabel: UILabel {
    private var padding = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    
    convenience init(padding: UIEdgeInsets) {
        self.init()
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        
        return contentSize
    }
}


// MARK: ✅ Extension - 현재 Locale 기반으로 날짜를 문자열로 변환해주는 간단 유틸
extension Date {
    
    /// 현지화된 날짜 문자열 반환
    /// - Parameters:
    ///   - dateStyle: 날짜 스타일 (기본값 .medium → 예: 2025. 11. 7.)
    ///   - timeStyle: 시간 스타일 (기본값 .none → 시간 미포함)
    ///   - locale: 사용할 Locale (기본값: .autoupdatingCurrent)
    /// - Returns: 지역/언어에 맞게 포맷팅된 문자열
    func localizedString(
        dateStyle: DateFormatter.Style = .medium,
        timeStyle: DateFormatter.Style = .none,
        locale: Locale = .autoupdatingCurrent
    ) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter.string(from: self)
    }
}
