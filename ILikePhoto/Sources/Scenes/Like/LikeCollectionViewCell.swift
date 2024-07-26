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
    let likeButton = UIButton().then {
        $0.setImage(MyImage.likeCircleInactive, for: .normal)
    }
    
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
        let url = URL(string: data.smallURL)
        mainImageView.kf.setImage(with: url)
    }
    
    func toggleLikeButton(isLike: Bool) {
        let image = isLike ? MyImage.likeCircle : MyImage.likeCircleInactive
        likeButton.setImage(image, for: .normal)
    }
}
