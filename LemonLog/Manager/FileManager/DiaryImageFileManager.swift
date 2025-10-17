//
//  DiaryImageFileManager.swift
//  LemonLog
//
//  Created by 권정근 on 10/16/25.
//

import Foundation
import UIKit


final class DiaryImageFileManager {
    
    
    // MARK: ✅ Singleton
    static let shared = DiaryImageFileManager()
    private init() {}
    
    
    // MARK: ✅ Property
    // 저장하려는 이미지를 담는 폴더명
    private let folderName: String = "EmotionDiaryImages"
    
    
    // MARK: ✅ Private Path Method
    private func getDocumentsDirectory() -> URL {
        guard let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            LogManager.print(.error, "Document 디렉토리를 찾을 수 없습니다.")
            return URL(fileURLWithPath: "")
        }
        
        let folder = doc.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: folder.path) {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                LogManager.print(.error, "이미지 폴더 생성 실패: \(error.localizedDescription)")
            }
        }
        return folder
    }
    
    private func getDiaryFolder(for diaryID: String) -> URL {
        let baseFolder = getDocumentsDirectory()
        let diaryFolder = baseFolder.appendingPathComponent(diaryID)
        
        if !FileManager.default.fileExists(atPath: diaryFolder.path) {
            do {
                try FileManager.default.createDirectory(at: diaryFolder, withIntermediateDirectories: true)
            } catch {
                LogManager.print(.error, "Diary 폴더 생성 실패 [\(diaryID)]: \(error.localizedDescription)")
            }
        }
        return diaryFolder
    }
    
    
    // MARK: ✅ Save
    @discardableResult
    func saveImage(_ image: UIImage, diaryID: String, index: Int) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            LogManager.print(.error, "JPEG 변환 실패")
            return nil
        }
        
        let fileName = "image_\(index).jpg"
        let fileURL = getDiaryFolder(for: diaryID).appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            LogManager.print(.success, "이미지 저장 성공: \(fileURL.lastPathComponent)")
            return "\(diaryID)/\(fileName)"
        } catch {
            LogManager.print(.error, "이미지 저장 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: ✅ Load
    func loadImage(from path: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(path)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            LogManager.print(.warning, "파일 없음: \(fileURL.lastPathComponent)")
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    
    // MARK: ✅ Delete (개별 이미지)
    func deleteImage(diaryID: String, index: Int) {
        let diaryFolder = getDiaryFolder(for: diaryID)
        let fileURL = diaryFolder.appendingPathComponent("image_\(index).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                LogManager.print(.success, "이미지 삭제 완료: \(fileURL.lastPathComponent)")
            } catch {
                LogManager.print(.error, "이미지 삭제 실패: \(error.localizedDescription)")
            }
        } else {
            LogManager.print(.warning, "삭제할 이미지 없음: \(fileURL.lastPathComponent)")
        }
    }
    
    
    // MARK: ✅ Delete (일기 전체 데이터)
    func deleteDiaryFolder(for diaryID: String) {
        let folderURL = getDocumentsDirectory().appendingPathComponent(diaryID)
        if FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.removeItem(at: folderURL)
                LogManager.print(.success, "\(diaryID) 폴더 삭제 완료")
            } catch {
                LogManager.print(.error, "폴더 삭제 실패: \(error.localizedDescription)")
            }
        } else {
            LogManager.print(.warning, "삭제할 폴더 없음: \(folderURL.lastPathComponent)")
        }
    }
    
    
    // MARK: ✅ Update (기존 이미지 교체)
    func updateImage(_ newImage: UIImage, diaryID: String, index: Int) -> String? {
        deleteImage(diaryID: diaryID, index: index)
        return saveImage(newImage, diaryID: diaryID, index: index)
    }
}
