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
