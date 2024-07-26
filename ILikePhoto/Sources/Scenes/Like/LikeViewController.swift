//
//  LikeViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import UIKit
import SnapKit
import Then

enum LikeSearchOrder: String {
    case descending, ascending
    
    var title: String {
        switch self {
        case .descending:
            return "최신순"
        case .ascending:
            return "과거순"
        }
    }
}

final class LikeViewController: BaseViewController {
    
    private lazy var sortButton = UIButton().then {
        $0.setTitle(searchOrder.title, for: .normal)
        $0.setTitleColor(MyColor.black, for: .normal)
        $0.titleLabel?.font = MyFont.bold14
        $0.tintColor = MyColor.black
        $0.setImage(MyImage.sort, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = MyColor.gray.cgColor
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        $0.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createLayout(spacing: 10, cellCount: 2, aspectRatio: 4/3)
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            LikeCollectionViewCell.self,
            forCellWithReuseIdentifier: LikeCollectionViewCell.description()
        )
    }
    private let emptyLabel = UILabel().then {
        $0.text = "저장된 사진이 없어요."
        $0.font = MyFont.bold20
        $0.textColor = MyColor.black
    }
    
    var list = [LikedPhoto]()
    var searchOrder = LikeSearchOrder.descending
//    var searchColor: SearchColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "MY POLAROID"
    }
    
    override func configureHierarchy() {
        [
            sortButton,
            collectionView,
            emptyLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureLayout() {
        sortButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(30)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureView() {
        list = RealmRepository.shared.fetchAll(searchOrder == .ascending)
        toggleHideView()
        collectionView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func toggleHideView() {
        emptyLabel.isHidden = !list.isEmpty
        collectionView.isHidden = list.isEmpty
    }
    
    @objc private func sortButtonTapped() {
        searchOrder = searchOrder == .ascending ? .descending : .ascending
        configureView()
    }
}

extension LikeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LikeCollectionViewCell.description(),
            for: indexPath
        ) as? LikeCollectionViewCell else { return UICollectionViewCell() }
        let data = list[indexPath.item]
        cell.configureCell(data: data)
        cell.likeButton.toggleButton(isLike: true)
        cell.likeButton.tag = indexPath.item
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc private func likeButtonTapped(sender: UIButton) {
        let data = list[sender.tag]
        // 1. 이미지 파일 삭제
        ImageFileManager.shared.deleteImageFile(filename: data.id)
        // 2. Realm 삭제
        RealmRepository.shared.deleteItem(data.id)
        // 뷰 업데이트
        configureView()
    }
    
    func photoResponseToLikedPhoto(_ value: PhotoResponse) -> LikedPhoto {
        return LikedPhoto(
            id: value.id,
            rawURL: value.urls.raw,
            smallURL: value.urls.small,
            width: value.width,
            height: value.height,
            likes: value.likes,
            color: value.color,
            createdAt: value.createdAt,
            photographerName: value.user.name,
            photographerImage: value.user.profileImage.medium
        )
    }
    
    func likedPhotoToPhotoResponse(_ value: LikedPhoto) -> PhotoResponse {
        return PhotoResponse(
            id: value.id,
            createdAt: value.createdAt,
            color: value.color,
            width: value.width,
            height: value.height,
            likes: value.likes,
            urls: Urls(raw: value.rawURL, small: value.smallURL),
            user: User(name: value.photographerName, profileImage: ProfileImage(medium: value.photographerImage))
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = DetailViewController()
        
        let data = list[indexPath.item]
        vc.photo = likedPhotoToPhotoResponse(data)
        navigationController?.pushViewController(vc, animated: true)
    }
}
