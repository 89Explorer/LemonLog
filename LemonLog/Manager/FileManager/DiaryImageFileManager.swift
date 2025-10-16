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
    static let sharded = DiaryImageFileManager()
    private init() {}
    
    
    // MARK: ✅ Property
    // 저장하려는 이미지를 담는 폴더명
    private let folderName: String = "EmotionDiaryImages"
    
    
    // MARK: ✅ Private Path Method
    private func getDocumentsDirectory() -> URL {
        guard let doc = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("❌ Document 디렉토리를 찾을 수 없습니다.")
        }
        
        let folder = doc.appendingPathComponent(folderName)
        if !FileManager.default.fileExists(atPath: folder.path) {
            do {
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            } catch {
                print("❌ 이미지 폴더 생성 실패:", error.localizedDescription)
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
                print("❌ Diary 폴더 생성 실패 [\(diaryID)]:", error.localizedDescription)
            }
        }
        return diaryFolder
    }
    
    
    // MARK: ✅ Save
    @discardableResult
    func saveImage(_ image: UIImage, diaryID: String, index: Int) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.75) else {
            print("❌ JEPG 변환 실패")
            return  nil
        }
        
        let fileName = "image_\(index).jpg"
        let fileURL = getDiaryFolder(for: diaryID).appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("✅ 이미지 저장 성공:", fileURL.lastPathComponent)
            return "\(diaryID)/\(fileName)"
        } catch {
            print("❌ 이미지 저장 실패:", error.localizedDescription)
            return nil
        }
        
    }
    
    
    // MARK: ✅ Load
    func loadImage(from path: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appending(path: path)
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("⚠️ 파일 없음:", fileURL.lastPathComponent)
            return nil
        }
        return UIImage(contentsOfFile: fileURL.path(percentEncoded: true))
    }
    
    
    // MARK: ✅ Delete (개별 이미지)
    func deleteImage(diaryID: String, index: Int) {
        let diaryFolder = getDiaryFolder(for: diaryID)
        let fileURL = diaryFolder.appending(path: "image_\(index).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("🗑️ 이미지 삭제 완료:", fileURL.lastPathComponent)
            } catch {
                print("❌ 이미지 삭제 실패:", error.localizedDescription)
            }
        } else {
            print("⚠️ 삭제할 이미지 없음:", fileURL.lastPathComponent)
        }
    }
    
    
    // MARK: ✅ Delete (일기 전체 데이터)
    func deleteDiaryFolder(for diaryID: String) {
        let folderURL = getDocumentsDirectory().appending(path: diaryID)
        if FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.removeItem(at: folderURL)
                print("🗑️ \(diaryID) 폴더 삭제 완료")
            } catch {
                print("❌ 폴더 삭제 실패:", error.localizedDescription)
            }
        }
    }
    
    
    // MARK: ✅ Update (기존 이미지 교체)
    func updateImage(_ newImage: UIImage, diaryID: String, index: Int) -> String? {
        deleteImage(diaryID: diaryID, index: index)
        return saveImage(newImage, diaryID: diaryID, index: index)
    }
}
