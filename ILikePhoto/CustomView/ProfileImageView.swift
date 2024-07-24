//
//  ProfileImageView.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

final class ProfileImageView: UIImageView {
    
    init() {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.width / 2
    }
    
    func setImageView(isSelect: Bool) {
        if isSelect {
            layer.borderWidth = 3
            layer.borderColor = MyColor.blue.cgColor
            alpha = 1
        } else {
            layer.borderWidth = 1
            layer.borderColor = MyColor.lightgray.cgColor
            alpha = 0.5
        }
    }
}
