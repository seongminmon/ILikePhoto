//
//  ColorCollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/27/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class ColorCollectionViewCell: BaseCollectionViewCell {
    
    let colorButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = MyImage.circle
        config.imagePadding = 8
        $0.configuration = config
        
        $0.setTitleColor(MyColor.black, for: .normal)
        $0.backgroundColor = MyColor.lightgray
        $0.layer.cornerRadius = 15
    }
    
    override func configureHierarchy() {
        contentView.addSubview(colorButton)
    }
    
    override func configureLayout() {
        colorButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
    
    func configureCell(color: SearchColor?) {
        guard let color else { return }
        colorButton.tintColor = UIColor.hexStringToUIColor(color.colorValue)
        colorButton.setTitle(color.description, for: .normal)
    }
}
