//
//  NetworkRouter.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation
import Alamofire

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

enum NetworkRouter {
    case topic(topicID: String)
    case search(query: String, page: Int, order: SearchOrder, color: SearchColor?)
    case statistics(imageID: String)
    case random
}

extension NetworkRouter: TargetType {
    var baseURL: String {
        return APIURL.baseURL
    }
    
    var path: String {
        switch self {
        case .topic(let topicID):
            return "topics/\(topicID)/photos"
        case .search:
            return "search/photos"
        case .statistics(let imageID):
            return  "photos/\(imageID)/statistics"
        case .random:
            return "photos/random"
        }
    }
    
    var endpoint: URL {
        return URL(string: baseURL + path)!
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters {
        switch self {
        case .topic:
            return [
                "page": 1,
                "client_id": APIKey.Key
            ]
        case .search(let query, let page, let order, let color):
            var ret: Parameters = [
                "query": query,
                "page": page,
                "per_page": 20,
                "order_by": order.rawValue,
                "client_id": APIKey.Key
            ]
            if let color {
                ret["color"] = color.rawValue
            }
            return ret
        case .statistics:
            return [
                "client_id": APIKey.Key
            ]
        case .random:
            return [
                "count": 10,
                "client_id": APIKey.Key
            ]
        }
    }
    
    var encoding: URLEncoding {
        return URLEncoding(destination: .queryString)
    }
}
