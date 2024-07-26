//
//  LikedPhoto.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import Foundation
import RealmSwift

class LikedPhoto: Object {
    // 사진 id를 기본키로 설정
    @Persisted(primaryKey: true) var id: String
    // 사진 URL
    @Persisted var rawURL: String
    @Persisted var smallURL: String
    // 사진 크기
    @Persisted var width: Int
    @Persisted var height: Int
    // 사진 좋아요 수
    @Persisted var likes: Int
    // 색깔 (hex)
    @Persisted var color: String
    // 사진 게시일
    @Persisted var createdAt: String
    // 작가 이름
    @Persisted var photographerName: String
    // 작가 프로필
    @Persisted var photographerImage: String
    // 좋아요한 날짜
    @Persisted var date: Date
    
    convenience init(id: String, rawURL: String, smallURL: String, width: Int, height: Int, likes: Int, color: String, createdAt: String, photographerName: String, photographerImage: String) {
        self.init()
        self.id = id
        self.rawURL = rawURL
        self.smallURL = smallURL
        self.width = width
        self.height = height
        self.likes = likes
        self.color = color
        self.createdAt = createdAt
        self.photographerName = photographerName
        self.photographerImage = photographerImage
        self.date = Date()
    }
}
