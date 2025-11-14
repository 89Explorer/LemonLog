//
//  MediaManager.swift
//  LemonLog
//
//  Created by 권정근 on 11/14/25.
//


import Foundation
import Photos
import AVFoundation
import UIKit


// MARK: ✅ MediaPermissionType - 카메라 및 앨범 접근권한 설정
enum MediaPermissionType {
    case camera
    case album
}


// MARK: ✅ PermissionStatus - 권한 선택 설정
enum PermissionStatus {
    case granted
    case denied
    case notDetermined
}


// MARK: ✅ MediaPermissionManager - 카메라, 앨범 접근권한 설정
final class MediaPermissionManager {
    
    static let shared = MediaPermissionManager()
    private init() { }
    
    // 권한 요청
    func request(_ type: MediaPermissionType, completion: @escaping (Bool) -> Void ) {
        
        switch type {
            
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
            
        case .album:
            
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                
                DispatchQueue.main.async {
    
                    switch status {
                    case .authorized, .limited:
                        completion(true)
                    default:
                        completion(false)
                        
                    }
                }
    
            }
        }
    }
    
    // 권한 체크
    func checkStatus(_ type: MediaPermissionType) -> PermissionStatus {
        switch type {
            
        case .camera:
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            switch status {
            case .authorized:
                return .granted
            case .notDetermined:
                return .notDetermined
            default:
                return .denied
            }
            
        case .album:
            return getAlbumStatus()
        }
    }
    
    private func getAlbumStatus() -> PermissionStatus {
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            return .granted
        case .notDetermined:
            return .notDetermined
        default:
            return .denied
        }
    }
    
    // 체크 후 필요 시 요청까지 처리
    func checkAndRequestIfNeeded(
        _ type: MediaPermissionType,
        completion: @escaping (Bool) -> Void
    ) {
        let status = checkStatus(type)
        
        switch status {
        case .granted:
            completion(true)
        case .notDetermined:
            request(type, completion: completion)
        case .denied:
            completion(false)
        }
    }
    
    // 설정 앱으로 이동 (거부된 경우)
    func openSettings() {
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        
    }
    
}



