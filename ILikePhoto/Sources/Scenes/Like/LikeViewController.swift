//
//  LikeViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/25/24.
//

import UIKit
import SnapKit
import Then
import Toast

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
    // TODO: - 통신에서 오는 hex가 enum값과 다른 문제
    // TODO: - 스크롤 위아래로 반복하면 레이아웃 겹치는 문제
    // TODO: - 삭제시 스크롤이 남아있는 문제
    
    private lazy var colorCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createColorButtonsLayout()
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.description()
        )
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
    }
    private lazy var sortButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.imagePadding = 8
        $0.configuration = config
        $0.setTitle(searchOrder.title, for: .normal)
        $0.setTitleColor(MyColor.black, for: .normal)
        $0.titleLabel?.font = MyFont.bold14
        $0.tintColor = MyColor.black
        $0.setImage(MyImage.sort, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = MyColor.gray.cgColor
        $0.addTarget(self, action: #selector(sortButtonTapped), for: .touchUpInside)
    }
    private lazy var pinterestLayout = PinterestLayout().then {
        $0.delegate = self
    }
    private lazy var mainCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: pinterestLayout
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
    var searchColor = Set<SearchColor>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        list = RealmRepository.shared.fetchAll(order: searchOrder, color: searchColor)
        updateView()
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "MY POLAROID"
    }
    
    override func configureHierarchy() {
        [
            colorCollectionView,
            sortButton,
            mainCollectionView,
            emptyLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureLayout() {
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(sortButton.snp.leading)
            $0.height.equalTo(30)
        }
        sortButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(30)
        }
        mainCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom).offset(8)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func updateView() {
        toggleHideView()
        mainCollectionView.reloadData()
//        UIView.animate(withDuration: 0.3) {
//            self.view.layoutIfNeeded()
//        }
    }
    
    private func toggleHideView() {
        emptyLabel.isHidden = !list.isEmpty
        mainCollectionView.isHidden = list.isEmpty
    }
    
    @objc private func sortButtonTapped() {
        searchOrder = searchOrder == .ascending ? .descending : .ascending
        sortButton.setTitle(searchOrder.title, for: .normal)
        list = RealmRepository.shared.fetchAll(order: searchOrder, color: searchColor)
        updateView()
        if !list.isEmpty {
            mainCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
}

extension LikeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorCollectionView {
            return SearchColor.allCases.count
        } else {
            return list.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == colorCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.description(),
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = SearchColor.allCases[indexPath.item]
            cell.configureCell(color: color)
            cell.toggleSelected(isSelect: searchColor.contains(color))
            return cell
        } else {
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
    }
    
    @objc private func likeButtonTapped(sender: UIButton) {
        let data = list[sender.tag]
        // 1. 이미지 파일 삭제
        ImageFileManager.shared.deleteImageFile(filename: data.id)
        ImageFileManager.shared.deleteImageFile(filename: data.id + "user")
        // 2. Realm 삭제
        RealmRepository.shared.deleteItem(data.id)
        // 3. list 삭제
        list.remove(at: sender.tag)
        // 뷰 업데이트
        updateView()
        makeRealmToast(false)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            let color = SearchColor.allCases[indexPath.item]
            if searchColor.contains(color) {
                searchColor.remove(color)
            } else {
                searchColor.insert(color)
            }
            colorCollectionView.reloadData()
            list = RealmRepository.shared.fetchAll(order: searchOrder, color: searchColor)
            updateView()
        } else {
            let data = list[indexPath.item].ToPhotoResponse()
            pushDetailViewController(data)
        }
    }
}

extension LikeViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let data = list[indexPath.item]
        let ratio = CGFloat(data.height) / CGFloat(data.width)
        let width = UIScreen.main.bounds.width / 2
        return width * ratio
    }
}
