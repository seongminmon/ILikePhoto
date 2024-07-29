//
//  LikeCollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class LikeCollectionViewCell: BaseCollectionViewCell {
    
    private let mainImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    let likeButton = LikeButton()
    
    override func configureHierarchy() {
        [
            mainImageView,
            likeButton
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        likeButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(mainImageView).inset(8)
            $0.size.equalTo(30)
        }
    }
    
    func configureCell(data: LikedPhoto?) {
        guard let data else { return }
        let image = ImageFileManager.shared.loadImageFile(filename: data.id) ?? MyImage.star
        mainImageView.image = image
    }
}
