//
//  DetailTableViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import SnapKit
import Then

final class DetailTableViewCell: BaseTableViewCell {
    
    let titleLabel = UILabel().then {
        $0.font = MyFont.bold14
    }
    let descriptionLabel = UILabel().then {
        $0.font = MyFont.regular14
    }
    
    override func configureHierarchy() {
        [
            titleLabel,
            descriptionLabel
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview().inset(8)
        }
        descriptionLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }
    
    func configureCell(title: String, description: String) {
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
