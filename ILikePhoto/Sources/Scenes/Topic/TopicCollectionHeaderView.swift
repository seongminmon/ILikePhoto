//
//  TopicCollectionHeaderView.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import SnapKit
import Then

final class TopicCollectionHeaderView: UICollectionReusableView {
    
    private let titleLabel = UILabel().then {
        $0.font = MyFont.bold20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(_ text: String) {
        titleLabel.text = text
    }
}
