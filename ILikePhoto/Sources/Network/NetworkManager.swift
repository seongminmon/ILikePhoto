//
//  NetworkManager.swift
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
        case .white:
            return "#FFFFFF"
        case .yellow:
            return "#FFEF62"
        case .red:
            return "#F04452"
        case .purple:
            return "#9636E1"
        case .green:
            return "#02B946"
        case .blue:
            return "#3C59FF"
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        api: NetworkRouter,
        model: T.Type,
        completionHandler: @escaping (Result<T, AFError>) -> Void
    ) {
        AF.request(
            api.endpoint,
            method: api.method,
            parameters: api.parameters,
            encoding: api.encoding
        )
        .validate(statusCode: 200..<500)
        .responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let value):
                print("SUCCESS", api)
                completionHandler(.success(value))
            case .failure(let error):
                print("FAIL", error)
                completionHandler(.failure(error))
            }
        }
    }
}
