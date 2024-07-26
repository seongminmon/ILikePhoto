//
//  TargetType.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import Foundation
import Alamofire

protocol TargetType {
    var baseURL: String { get }
    var path: String { get }
    var endpoint: URL { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }
    var encoding: URLEncoding { get }
}
