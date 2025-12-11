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
    private var padding = UIEdgeInsets(top: 4.0, left: 8.0, bottom: 4.0, right: 8.0)
    
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
    
    // 2025-02-15 13:22:14 ----> (stripped) 2025-02-15 00:00:00
    func stripped() -> Date {
        Calendar.current.startOfDay(for: self)
    }
}


// MARK: ✅ Extension - 해당 뷰를 포함하고 있는 가장 가까운 UIViewController 객체를 차는 유틸
/*
 이 parentViewController 계산 속성은 다음과 같은 상황에서 매우 유용합니다.

  1.뷰 컴포넌트 내부에서 액션 처리:
 사용자 정의 UIView 클래스(예: 커스텀 버튼) 내에서 버튼을 탭했을 때,
 해당 뷰의 로직이 아닌 뷰 컨트롤러의 로직을 실행해야 할 때
 뷰 컨트롤러 인스턴스에 접근하는 가장 깔끔한 방법 중 하나입니다.

  2.화면 전환(Navigation):
 뷰 내부에서 모달 뷰를 띄우거나, 다른 화면으로 푸시(Push)할 때,
 해당 작업을 수행할 프레젠테이션 컨트롤러 (바로 이 parentViewController)를 찾기 위해 사용됩니다.

  3.코드 분리:
 UIView는 오직 UI 요소에만 집중하고, 데이터 처리나 화면 관리는
 UIViewController에게 위임하는 책임 분리 원칙을 지키는 데 도움을 줍니다.
 */
extension UIView {

    var parentViewController: UIViewController? {
        
        var parentResponse: UIResponder? = self
        while parentResponse != nil {
            parentResponse = parentResponse?.next
            if let vc = parentResponse as? UIViewController {
                return vc
            }
        }
        return nil
    }
    
}


// MARK: ✅ Extension - UIImage 사이즈 조절 
extension UIImage {
    func resized(maxWidth: CGFloat = 1200) -> UIImage? {
        let scale = maxWidth / self.size.width
        let newSize = CGSize(width: maxWidth,
                             height: self.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}


// MARK: ✅ Extension -> UIViewController
extension UIViewController {

    // dim view tag
    private var dimViewTag: Int { 987654 }

    
    func showDim(animated: Bool = true, alpha: CGFloat = 0.35) {
        // 이미 존재하면 재생성 X
        if let _ = view.viewWithTag(dimViewTag) { return }

        let dim = UIView(frame: view.bounds)
        dim.backgroundColor = UIColor.black.withAlphaComponent(alpha)
        dim.alpha = 0
        dim.tag = dimViewTag
        view.addSubview(dim)

        if animated {
            UIView.animate(withDuration: 0.25) {
                dim.alpha = 1
            }
        } else {
            dim.alpha = 1
        }
    }

    
    func hideDim(animated: Bool = true) {
        guard let dim = view.viewWithTag(dimViewTag) else { return }

        if animated {
            UIView.animate(withDuration: 0.15, animations: {
                dim.alpha = 0
            }) { _ in
                dim.removeFromSuperview()
            }
        } else {
            dim.removeFromSuperview()
        }
    }
    
    // showAlert과 같은 공통 UI 기능을 어디서든 호출할 수 있도록 하려면,
    // 해당 기능을 UIViewController의 확장(Extension) 또는 별도의 유틸리티 클래스로 분리해야 합니다.
    func showAlert(title: String = "⚠️알림", message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        
        // Alert을 호출하는 UIViewController 인스턴스가 직접 Present합니다.
        self.present(alert, animated: true)
    }
    
}


// MARK: ✅ Extension - Hepler Method
extension Calendar {
    
    // 어떤 날짜가 오더라도 그 달의 1일 00:00 정규화
    func startOfMonth(for day: Date) -> Date {
        let comps = dateComponents([.year, .month], from: day)
        return self.date(from: comps)!   // ← self.date 로 명확히
    }
    
    func isSameDay(_ a: Date, _ b: Date) -> Bool {
        isDate(a, inSameDayAs: b)
    }

    func isSameMonth(_ a: Date, _ b: Date) -> Bool {
        isDate(a, equalTo: b, toGranularity: .month)
    }
    
}


// MARK: ✅ TopAlignedLabel
final class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        // 텍스트 높이를 계산
        guard let text = self.text else {
            super.drawText(in: rect)
            return
        }

        let textRect = (text as NSString).boundingRect(
            with: CGSize(width: rect.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: self.font as Any],
            context: nil
        )

        // 상단 정렬
        let newRect = CGRect(
            x: rect.origin.x,
            y: rect.origin.y,  // ← 여기! 상단으로 고정
            width: rect.width,
            height: textRect.height
        )

        super.drawText(in: newRect)
    }
}
