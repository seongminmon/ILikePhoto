//
//  SearchOption.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/29/24.
//

import Foundation

enum SearchOrder: String {
    case relevant, latest
    
    var title: String {
        switch self {
        case .relevant:
            return "관련순"
        case .latest:
            return "최신순"
        }
    }
}

enum SearchColor: String, CaseIterable {
    case black
    case white
    case yellow
    case red
    case purple
    case green
    case blue
    
    var description: String {
        switch self {
        case .black:
            return "블랙"
        case .white:
            return "화이트"
        case .yellow:
            return "옐로우"
        case .red:
            return "레드"
        case .purple:
            return "퍼플"
        case .green:
            return "그린"
        case .blue:
            return "블루"
        }
    }
    
    var colorValue: String {
        switch self {
        case .black:
            return "#000000"
        case .green:
            return "#02B946"
        case .purple:
            return "#9636E1"
        case .blue:
            return "#3C59FF"
        case .red:
            return "#F04452"
        case .yellow:
            return "#FFEF62"
        case .white:
            return "#FFFFFF"
        }
    }
}
