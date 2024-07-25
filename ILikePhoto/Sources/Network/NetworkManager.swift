//
//  NetworkManager.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation
import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        api: NetworkRequest,
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
    
    // 토픽
//    NetworkManager.shared.request(api: .topic(topicID: "wallpapers"), model: [PhotoResponse].self) { response in
//        switch response {
//        case .success(let data):
//            print("=====토픽=====")
//            dump(data)
//        case .failure(let error):
//            print(error)
//        }
//    }
    
    // 서치
//    NetworkManager.shared.request(api: .search(query: "나무", page: 1, order: .relevant, color: nil), model: [PhotoResponse].self) { response in
//        switch response {
//        case .success(let data):
//            print("=====서치=====")
//            dump(data)
//        case .failure(let error):
//            print(error)
//        }
//    }
//    
    
    // 분석
//    NetworkManager.shared.request(api: .statistics(imageID: "wnmv8JH2ri8"), model: StatisticsResponse.self) { response in
//        switch response {
//        case .success(let data):
//            print("=====분석=====")
//            dump(data)
//        case .failure(let error):
//            print(error)
//        }
//    }
//    
    // 랜덤
//    NetworkManager.shared.request(api: .random, model: [PhotoResponse].self) { response in
//        switch response {
//        case .success(let data):
//            print("=====랜덤=====")
//            dump(data)
//        case .failure(let error):
//            print(error)
//        }
//    }
}
