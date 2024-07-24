//
//  TopicCollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then

final class TopicCollectionViewCell: BaseCollectionViewCell {
    // TODO: - 버튼 디자인 완성하기
    private let mainImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    private let starButton = UIButton().then {
        $0.setImage(MyImage.star.withTintColor(.systemYellow), for: .normal)
        $0.setTitleColor(MyColor.white, for: .normal)
        $0.backgroundColor = MyColor.darkgray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    override func configureHierarchy() {
        [mainImageView, starButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        starButton.snp.makeConstraints {
            $0.leading.bottom.equalTo(mainImageView).inset(8)
        }
    }
    
    func configureCell(data: PhotoResponse) {
        let url = URL(string: data.urls.small)
        mainImageView.kf.setImage(with: url)
        starButton.setTitle(data.likes.formatted(), for: .normal)
    }
}
