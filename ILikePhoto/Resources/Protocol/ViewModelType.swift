//
//  ViewModelType.swift
//  ILikePhoto
//
//  Created by 김성민 on 8/8/24.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
