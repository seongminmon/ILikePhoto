//
//  MBTICollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/29/24.
//

import UIKit
import SnapKit
import Then

final class MBTICollectionViewCell: BaseCollectionViewCell {
    
    private let containerView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = MyColor.darkgray.cgColor
    }
    private let mainLabel = UILabel().then {
        $0.font = MyFont.regular16
        $0.textColor = MyColor.darkgray
        $0.textAlignment = .center
    }
    
    override func configureHierarchy() {
        containerView.addSubview(mainLabel)
        contentView.addSubview(containerView)
    }
    
    override func configureLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mainLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
    
    func configureCell(text: String) {
        mainLabel.text = text
    }
    
    func toggleSelected(isSelect: Bool) {
        if isSelect {
            mainLabel.textColor = MyColor.white
            containerView.backgroundColor = MyColor.blue
            containerView.layer.borderColor = MyColor.blue.cgColor
        } else {
            mainLabel.textColor = MyColor.darkgray
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = MyColor.darkgray.cgColor
        }
    }
}
