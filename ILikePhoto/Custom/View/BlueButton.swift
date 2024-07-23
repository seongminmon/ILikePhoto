//
//  BlueButton.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

final class BlueButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(Design.Color.white, for: .normal)
        titleLabel?.font = Design.Font.bold16
        backgroundColor = Design.Color.blue
        layer.cornerRadius = 20
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
