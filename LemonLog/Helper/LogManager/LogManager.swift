//
//  LogManager.swift
//  LemonLog
//
//  Created by 권정근 on 10/17/25.
//

import Foundation


// MARK: ✅ enum
enum LogType: String {
    case info = "ℹ️"
    case success = "✅"
    case warning = "⚠️"
    case error = "❌"
}


// MARK: ✅ class
final class LogManager {
    static func print(_ type: LogType, _ message: String, _ function: String = #function, line: Int = #line) {
        #if DEBUG
        Swift.print("\(type.rawValue) [\(function):\(line)] - \(message)")
        #endif
    }
}
