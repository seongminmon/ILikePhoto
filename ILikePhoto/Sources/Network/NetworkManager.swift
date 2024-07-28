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
