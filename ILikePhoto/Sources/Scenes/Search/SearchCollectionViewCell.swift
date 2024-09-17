//
//  SearchCollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import UIKit
import Kingfisher
import RxSwift
import SnapKit
import Then

final class SearchCollectionViewCell: BaseCollectionViewCell {
    
    let mainImageView = UIImageView()//.then {
//        $0.clipsToBounds = true
//        $0.layer.cornerRadius = 20
//    }
    private func starButtonConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        var titleAttr = AttributedString()
        titleAttr.font = MyFont.regular14
        config.attributedTitle = titleAttr
        config.image = MyImage.star.withRenderingMode(.alwaysOriginal)
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = MyColor.black.withAlphaComponent(0.3)
        config.baseForegroundColor = MyColor.white
        config.cornerStyle = .capsule
        config.buttonSize = .small
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        return config
    }
    private lazy var starButton = UIButton(configuration: starButtonConfig())
    let likeButton = LikeButton()
    var disposeBag = DisposeBag()
    
    // MARK: - cell 재사용 전에 이미지뷰 초기화 해주기, 구독 중첩 막기
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImageView.image = nil
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        [
            mainImageView,
            starButton,
            likeButton
        ].forEach {
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
        likeButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(mainImageView).inset(8)
            $0.size.equalTo(30)
        }
    }
    
    func configureCell(data: PhotoResponse?) {
        guard let data else { return }
        let url = URL(string: data.urls.small)
        mainImageView.kf.setImage(with: url)
        starButton.configuration?.title = data.likes.formatted()
    }
}
