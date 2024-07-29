//
//  NetworkRouter.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation
import Alamofire

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
