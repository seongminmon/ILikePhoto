//
//  SelectImageCollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/23/24.
//

import UIKit
import SnapKit

final class SelectImageCollectionViewCell: BaseCollectionViewCell {
    
    let profileImageView = ProfileImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureCell(index: Int, selectedIndex: Int) {
        profileImageView.image = Design.Image.profileImageList[index]
        profileImageView.setImageView(isSelect: index == selectedIndex)
    }
}
