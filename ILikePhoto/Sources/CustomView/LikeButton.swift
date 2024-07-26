//
//  LikeButton.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit

final class LikeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(MyImage.likeCircleInactive, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleButton(isLike: Bool) {
        let image = isLike ? MyImage.likeCircle : MyImage.likeCircleInactive
        setImage(image, for: .normal)
    }
}
