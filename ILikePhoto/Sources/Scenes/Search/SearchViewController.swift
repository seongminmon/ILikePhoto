//
//  SearchViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import Kingfisher
import SnapKit
import Then
import Toast

final class SearchViewController: BaseViewController {
    
    private lazy var searchBar = UISearchBar().then {
        $0.placeholder = "키워드 검색"
        $0.delegate = self
    }
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
        $0.backgroundColor = MyColor.white
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
        $0.prefetchDataSource = self
        $0.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.description()
        )
        $0.keyboardDismissMode = .onDrag
    }
    private let emptyLabel = UILabel().then {
        $0.text = "사진을 검색해보세요."
        $0.font = MyFont.bold20
        $0.textColor = MyColor.black
    }
    
    var list: SearchResponse?
    var query: String?
    var page = 1
    var searchOrder = SearchOrder.relevant
    var searchColor: SearchColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleHideView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainCollectionView.reloadData()
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "SEARCH PHOTO"
    }
    
    override func configureHierarchy() {
        [
            searchBar,
            colorCollectionView,
            sortButton,
            mainCollectionView,
            emptyLabel
        ].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(sortButton.snp.leading)
            $0.height.equalTo(30)
        }
        sortButton.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(8)
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
    
    private func toggleHideView() {
        if let list, !list.photoResponse.isEmpty {
            emptyLabel.isHidden = true
            mainCollectionView.isHidden = false
        } else {
            emptyLabel.isHidden = false
            mainCollectionView.isHidden = true
        }
    }
    
    @objc private func sortButtonTapped() {
        guard let query = validateQuery(query) else { return }
        page = 1
        searchOrder = searchOrder == .relevant ? .latest : .relevant
        sortButton.setTitle(searchOrder.title, for: .normal)
        fetchSearch(query)
    }
    
    private func validateQuery(_ query: String?) -> String? {
        if let query = query, !query.trimmingCharacters(in: .whitespaces).isEmpty {
            return query.trimmingCharacters(in: .whitespaces)
        } else {
            view.makeToast("쿼리가 비었습니다!", duration: 1, position: .center)
            return nil
        }
    }
    
    private func fetchSearch(_ query: String) {
        // 통신 이후
        emptyLabel.text = "검색 결과가 없습니다."
        
        NetworkManager.shared.request(
            api: .search(query: query, page: page, order: searchOrder, color: searchColor),
            model: SearchResponse.self
        ) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let data):
                if page == 1 {
                    // 첫 검색
                    list = data
                } else {
                    // 페이지 네이션
                    list?.photoResponse.append(contentsOf: data.photoResponse)
                }
                
                toggleHideView()
                mainCollectionView.reloadData()
                
                if page == 1, let list, !list.photoResponse.isEmpty {
                    mainCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
                }
                
            case .failure(_):
                makeNetworkFailureToast()
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        query = validateQuery(searchBar.text)
        guard let query = query else { return }
        page = 1
        fetchSearch(query)
        view.endEditing(true)
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == colorCollectionView {
            return SearchColor.allCases.count
        } else {
            return list?.photoResponse.count ?? 0
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
            cell.toggleSelected(isSelect: color == searchColor)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchCollectionViewCell.description(),
                for: indexPath
            ) as? SearchCollectionViewCell,
                  let data = list?.photoResponse[indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.configureCell(data: data)
            cell.likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(data.id) != nil)
            cell.likeButton.tag = indexPath.item
            cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
            return cell
        }
    }
    
    @objc private func likeButtonTapped(sender: UIButton) {
        guard let cell = mainCollectionView.cellForItem(
            at: IndexPath(item: sender.tag, section: 0)
        ) as? SearchCollectionViewCell,
              let data = list?.photoResponse[sender.tag] else {
            return
        }
        
        if RealmRepository.shared.fetchItem(data.id) != nil {
            // 1. 이미지 파일 삭제
            ImageFileManager.shared.deleteImageFile(filename: data.id)
            ImageFileManager.shared.deleteImageFile(filename: data.id + "user")
            // 2. Realm 삭제
            RealmRepository.shared.deleteItem(data.id)
            // 3. 버튼 업데이트
            cell.likeButton.toggleButton(isLike: false)
            makeRealmToast(false)
        } else {
            // 1. Realm 추가
            let item = data.toLikedPhoto()
            RealmRepository.shared.addItem(item)
            // 2. 이미지 파일 추가
            let image = cell.mainImageView.image ?? MyImage.star
            ImageFileManager.shared.saveImageFile(image: image, filename: data.id)
            
            if let url = URL(string: item.photographerImage) {
                KingfisherManager.shared.retrieveImage(with: url) { result in
                    switch result {
                    case .success(let imageResult):
                        let profileImage = imageResult.image
                        ImageFileManager.shared.saveImageFile(image: profileImage, filename: data.id + "user")
                    case .failure(_):
                        print("작가 이미지 변환 실패")
                    }
                }
            }
            // 3. 버튼 업데이트
            cell.likeButton.toggleButton(isLike: true)
            makeRealmToast(true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            if searchColor != SearchColor.allCases[indexPath.item] {
                searchColor = SearchColor.allCases[indexPath.item]
            } else {
                searchColor = nil
            }
            colorCollectionView.reloadData()
            guard let query = validateQuery(query) else { return }
            page = 1
            fetchSearch(query)
        } else {
            let data = list?.photoResponse[indexPath.item]
            pushDetailViewController(data)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // 페이지네이션
        guard let query = validateQuery(query), let list else { return }
        for indexPath in indexPaths {
            if indexPath.item == list.photoResponse.count - 4 && page < list.totalPages {
                page += 1
                fetchSearch(query)
            }
        }
    }
}

extension SearchViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let data = list?.photoResponse[indexPath.item] else { return 0 }
        let ratio = CGFloat(data.height) / CGFloat(data.width)
        let width = UIScreen.main.bounds.width / 2
        return width * ratio
    }
}
