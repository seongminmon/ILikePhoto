//
//  UnsplashRouter.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation
import Alamofire

struct SearchParameter {
    var order: SearchOrder = .relevant
    var color: SearchColor?
    var query: String = ""
    var page: Int = 1
}

// TODO: - 쿼리 파라미터 객체화

enum UnsplashRouter {
    case topic(topicID: String)
    case search(searchParameter: SearchParameter)
    case statistics(imageID: String)
    case random
}

extension UnsplashRouter: TargetType {
    
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
        case .search(let searchParameter):
            var ret: Parameters = [
                "query": searchParameter.query,
                "page": searchParameter.page,
                "per_page": 20,
                "order_by": searchParameter.order.rawValue,
                "client_id": APIKey.Key
            ]
            if let color = searchParameter.color {
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
