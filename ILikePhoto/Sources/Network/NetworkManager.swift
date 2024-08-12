//
//  NetworkManager.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import Foundation
import Alamofire
import RxSwift

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func requestWithSingle<T: Decodable>(
        api: UnsplashRouter,
        model: T.Type
    ) -> Single<Result<T, AFError>> {
        let result = Single<Result<T, AFError>>.create { observer in
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
                    observer(.success(.success(value)))
                case .failure(let error):
                    print("FAIL", error)
                    observer(.success(.failure(error)))
                }
            }
            return Disposables.create()
        }
        return result
    }
    
//    func requestWithObservable<T: Decodable>(
//        api: UnsplashRouter,
//        model: T.Type
//    ) -> Observable<Result<T, AFError>> {
//        let result = Observable<Result<T, AFError>>.create { observer in
//            AF.request(
//                api.endpoint,
//                method: api.method,
//                parameters: api.parameters,
//                encoding: api.encoding
//            )
//            .validate(statusCode: 200..<500)
//            .responseDecodable(of: T.self) { response in
//                switch response.result {
//                case .success(let value):
//                    print("SUCCESS", api)
//                    observer.onNext(.success(value))
//                    observer.onCompleted()
//                case .failure(let error):
//                    print("FAIL", error)
//                    observer.onError(error)
//                }
//            }
//            return Disposables.create()
//        }
//        return result
//    }
    
//    func request<T: Decodable>(
//        api: NetworkRouter,
//        model: T.Type,
//        completionHandler: @escaping (Result<T, AFError>) -> Void
//    ) {
//        AF.request(
//            api.endpoint,
//            method: api.method,
//            parameters: api.parameters,
//            encoding: api.encoding
//        )
//        .validate(statusCode: 200..<500)
//        .responseDecodable(of: T.self) { response in
//            switch response.result {
//            case .success(let value):
//                print("SUCCESS", api)
//                completionHandler(.success(value))
//            case .failure(let error):
//                print("FAIL", error)
//                completionHandler(.failure(error))
//            }
//        }
//    }
}
