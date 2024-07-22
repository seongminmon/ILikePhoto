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
        titleLabel?.font = Design.Font.regular16
        layer.borderWidth = 1
        layer.cornerRadius = 20
        
        setTitleColor(Design.Color.darkgray, for: .normal)
        backgroundColor = .clear
        layer.borderColor = Design.Color.darkgray.cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButton(isSelect: Bool) {
        if isSelect {
            setTitleColor(Design.Color.white, for: .normal)
            backgroundColor = Design.Color.blue
            layer.borderColor = Design.Color.blue.cgColor
        } else {
            setTitleColor(Design.Color.darkgray, for: .normal)
            backgroundColor = .clear
            layer.borderColor = Design.Color.darkgray.cgColor
        }
    }
}
