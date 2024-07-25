//
//  PhotoResponse.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation

// MARK: - Search 모델
struct SearchResponse: Decodable {
    let total: Int
    let totalPages: Int
    var photoResponse: [PhotoResponse]
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case photoResponse = "results"
    }
}

// MARK: - Topic, Random 모델
struct PhotoResponse: Decodable, Hashable {
    let id, createdAt, color: String
    let width, height, likes: Int
    let urls: Urls
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, likes, urls, user, color
        case createdAt = "created_at"
    }
}

struct Urls: Decodable, Hashable {
    let raw: String
    let small: String
}

struct User: Decodable, Hashable {
    let name: String
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case name
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Decodable, Hashable {
    let medium: String
}
