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
    
    private let mainImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    private let logoImageView = UIImageView().then {
        $0.image = MyImage.likeInactive
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .white
    }
    private let countLabel = UILabel().then {
        $0.font = MyFont.regular14
        $0.textColor = .myWhite
    }
    
    override func configureHierarchy() {
        [
            mainImageView,
            logoImageView,
            countLabel
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        countLabel.snp.makeConstraints {
            $0.trailing.bottom.equalTo(mainImageView).inset(8)
        }
        logoImageView.snp.makeConstraints {
            $0.verticalEdges.equalTo(countLabel)
            $0.trailing.equalTo(countLabel.snp.leading).offset(-8)
            $0.width.equalTo(logoImageView.snp.height)
        }
    }
    
    func configureCell(data: PhotoResponse?) {
        guard let data else { return }
        let url = URL(string: data.urls.small)
        mainImageView.kf.setImage(with: url)
        countLabel.text = data.likes.formatted()
    }
}
