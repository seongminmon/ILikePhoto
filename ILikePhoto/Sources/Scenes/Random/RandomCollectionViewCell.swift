//
//  RandomCollectionViewCell.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import Kingfisher
import RxSwift
import SnapKit
import Then

final class RandomCollectionViewCell: BaseCollectionViewCell {
    
    let mainImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    private let labelcontainerView = UIView().then {
        $0.backgroundColor = MyColor.darkgray
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
    }
    private let pageLabel = UILabel().then {
        $0.font = MyFont.regular14
        $0.textColor = MyColor.white
    }
    private let footerView = UIView()
    private let photographerImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
    }
    private let photographerNameLabel = UILabel().then {
        $0.font = MyFont.regular15
        $0.textColor = MyColor.white
    }
    private let createAtLabel = UILabel().then {
        $0.font = MyFont.bold14
        $0.textColor = MyColor.white
    }
    lazy var likeButton = LikeButton().then {
        $0.toggleButton(isLike: false)
    }
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        labelcontainerView.addSubview(pageLabel)
        [
            photographerImageView,
            photographerNameLabel,
            createAtLabel,
            likeButton,
        ].forEach {
            footerView.addSubview($0)
        }
        [
            mainImageView,
            labelcontainerView,
            footerView
        ].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        labelcontainerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(60)
            $0.trailing.equalToSuperview().inset(16)
        }
        pageLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(8)
        }
        footerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
            $0.bottom.equalToSuperview().inset(80)
        }
        photographerImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(8)
            $0.size.equalTo(40)
        }
        photographerNameLabel.snp.makeConstraints {
            $0.top.equalTo(photographerImageView)
            $0.leading.equalTo(photographerImageView.snp.trailing).offset(4)
            $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
            $0.height.equalTo(20)
        }
        createAtLabel.snp.makeConstraints {
            $0.bottom.equalTo(photographerImageView)
            $0.leading.equalTo(photographerNameLabel)
            $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
            $0.height.equalTo(20)
        }
        likeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
            $0.size.equalTo(40)
        }
    }
    
    func configureCell(_ data: PhotoResponse, page: Int) {
        let mainURL = URL(string: data.urls.small)
        mainImageView.kf.setImage(with: mainURL)
        pageLabel.text = "\(page + 1)/10"
        let photographerURL = URL(string: data.user.profileImage.medium)
        photographerImageView.kf.setImage(with: photographerURL)
        photographerNameLabel.text = data.user.name
        createAtLabel.text = data.createdAt
    }
}
