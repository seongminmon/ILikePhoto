//
//  MBTIButton.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

enum MBTI: String {
    case E, S, T, J, I, N, F, P
}

final class MBTIButton: UIButton {
    
    init(title: MBTI) {
        super.init(frame: .zero)
        setTitle(title.rawValue, for: .normal)
        titleLabel?.font = Design.Font.regular16
        layer.cornerRadius = 20
        layer.borderWidth = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleButton(isSelect: Bool) {
        if isSelect {
            setTitleColor(Design.Color.white, for: .normal)
            backgroundColor = Design.Color.blue
            layer.borderColor = Design.Color.blue.cgColor
        } else {
            setTitleColor(Design.Color.lightgray, for: .normal)
            backgroundColor = .clear
            layer.borderColor = Design.Color.lightgray.cgColor
        }
    }
}
