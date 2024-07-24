//
//  StatisticsResponse.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/23/24.
//

import Foundation

// MARK: - statistics 모델
struct StatisticsResponse: Decodable {
    let id: String
    let downloads: Downloads
    let views: Views
}

struct Downloads: Decodable {
    let total: Int
    let historical: Historical
}

struct Views: Decodable {
    let total: Int
    let historical: Historical
}

struct Historical: Decodable {
    let values: [Values]
}

struct Values: Decodable {
    let date: String
    let value: Int
}
