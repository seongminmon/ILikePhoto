//
//  MBTIButton.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

final class MBTIButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel?.font = MyFont.regular16
        layer.borderWidth = 1
        layer.cornerRadius = 20
        setButton(isSelect: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButton(isSelect: Bool) {
        if isSelect {
            setTitleColor(MyColor.white, for: .normal)
            backgroundColor = MyColor.blue
            layer.borderColor = MyColor.blue.cgColor
        } else {
            setTitleColor(MyColor.darkgray, for: .normal)
            backgroundColor = .clear
            layer.borderColor = MyColor.darkgray.cgColor
        }
    }
}
