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
    
    private let containerView = UIView().then {
        $0.backgroundColor = MyColor.lightgray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
    }
    private let colorImageView = UIImageView().then {
        $0.image = MyImage.circle
    }
    private let colorLabel = UILabel().then {
        $0.font = MyFont.bold14
        $0.textColor = MyColor.blue
        $0.textAlignment = .center
    }
    
    override func configureHierarchy() {
        [
            colorImageView,
            colorLabel
        ].forEach {
            containerView.addSubview($0)
        }
        contentView.addSubview(containerView)
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(30)
        }
        colorImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(8)
            $0.size.equalTo(22)
        }
        colorLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(colorImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
        }
    }
    
    func configureCell(color: SearchColor?) {
        guard let color else { return }
        colorImageView.tintColor = UIColor.hexStringToUIColor(color.colorValue)
        colorLabel.text = color.description
    }
    
    func toggleSelected(isSelect: Bool) {
        if isSelect {
            colorLabel.textColor = MyColor.white
            containerView.backgroundColor = MyColor.blue
        } else {
            colorLabel.textColor = MyColor.black
            containerView.backgroundColor = MyColor.lightgray
        }
    }
}
