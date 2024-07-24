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
    
    private let mainImageView = UIImageView()
    
    override func configureHierarchy() {
        contentView.addSubview(mainImageView)
    }
    
    override func configureLayout() {
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureCell(_ urlString: String) {
        let url = URL(string: urlString)
        mainImageView.kf.setImage(with: url)
    }
}

