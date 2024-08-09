//
//  ImageFileManager.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import UIKit
import Kingfisher
import RxSwift

final class ImageFileManager {
    static let shared = ImageFileManager()
    private init() {}
    
    // 도큐먼트 폴더 위치
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // MARK: - Create, Update(이미 존재하는 파일명으로 저장하면 덮어쓰기)
    func saveImageFile(image: UIImage, filename: String) {
        //이미지를 저장할 경로(파일명) 지정
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        
        //이미지 압축
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        //이미지 파일 저장
        do {
            try data.write(to: fileURL)
        } catch {
            print("file save error", error)
        }
    }
    
    // urlString으로 저장
    func saveImageFile(url: String, filename: String) {
        url.urlToUIImage { [weak self] image in
            guard let image = image else { return }
            self?.saveImageFile(image: image, filename: filename)
        }
    }
    
    // MARK: - Read
    func loadImageFile(filename: String) -> UIImage? {
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        
        // 이 경로에 실제로 파일이 존재하는 지 확인
        if #available(iOS 16.0, *) {
            if FileManager.default.fileExists(atPath: fileURL.path()) {
                return UIImage(contentsOfFile: fileURL.path())
            } else {
                return nil
            }
        } else {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            } else {
                return nil
            }
        }
    }

    // MARK: - Delete
    func deleteImageFile(filename: String) {
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        
        if #available(iOS 16.0, *) {
            if FileManager.default.fileExists(atPath: fileURL.path()) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path())
                } catch {
                    print("file remove error", error)
                }
            } else {
                print("file no exist")
            }
        } else {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                } catch {
                    print("file remove error", error)
                }
            } else {
                print("file no exist")
            }
        }
    }
}
