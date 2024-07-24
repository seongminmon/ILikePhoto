//
//  PhotoResponse.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation

// MARK: - Topic, Search, Random 모델
struct PhotoResponse: Decodable {
    let id, createdAt: String
    let width, height, likes: Int
    let urls: Urls
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, likes, urls, user
        case createdAt = "created_at"
    }
}

struct Urls: Decodable {
    let raw: String
    let small: String
}

struct User: Decodable {
    let name: String
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case name
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable {
    let medium: String
}