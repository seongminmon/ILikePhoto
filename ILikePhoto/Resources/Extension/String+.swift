//
//  String+.swift
//  ILikePhoto
//
//  Created by 김성민 on 8/9/24.
//

import UIKit
import Kingfisher

extension String {
    func urlToUIImage(handler: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: self) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let imageResult):
                handler(imageResult.image)
            case .failure(_):
                print("이미지 변환 실패")
                handler(nil)
            }
        }
    }
    
    func dateToString() -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: self) {
            return date.formatted(date: .numeric, time: .omitted)
        } else {
            return ""
        }
    }
}
