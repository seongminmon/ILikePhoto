//
//  SearchViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import SnapKit
import Then

enum SearchOrder: String {
    case relevant, latest
    
    var title: String {
        switch self {
        case .relevant:
            return "관련순"
        case .latest:
            return "최신순"
        }
    }
}

// TODO: - 더 적절한 데이터 구조로 바꾸기
enum SearchColor: String {
    case black, white, yellow, red, purple, green, blue
}

final class SearchViewController: BaseViewController {
    
    private lazy var searchBar = UISearchBar().then {
        $0.placeholder = "키워드 검색"
        $0.delegate = self
    }
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
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .createLayout(spacing: 10, cellCount: 2, aspectRatio: 4/3)).then {
        $0.delegate = self
        $0.dataSource = self
        $0.prefetchDataSource = self
        $0.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.description())
        $0.keyboardDismissMode = .onDrag
    }
    private let emptyLabel = UILabel().then {
        $0.text = "사진을 검색해보세요."
        $0.font = MyFont.bold20
        $0.textColor = MyColor.black
    }
    
    // TODO: - 페이지 네이션
    // 통신하는 상황
    // 1. 서치바 검색 -> 첫 검색
    // 2. 정렬 버튼 -> 첫 검색
    // 3. 스크롤 내리기 -> 페이지네이션
    var list: SearchResponse?
    var page = 1
    var searchOrder = SearchOrder.relevant
//    var searchColor: SearchColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toggleHideView()
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "SEARCH PHOTO"
    }
    
    override func configureHierarchy() {
        [searchBar, sortButton, collectionView, emptyLabel].forEach {
            view.addSubview($0)
        }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(44)
        }
        sortButton.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(4)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(30)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(sortButton.snp.bottom)
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func toggleHideView() {
        if let list, !list.photoResponse.isEmpty {
            emptyLabel.isHidden = true
            collectionView.isHidden = false
        } else {
            emptyLabel.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    @objc private func sortButtonTapped() {
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        searchOrder = searchOrder == .relevant ? .latest : .relevant
        sortButton.setTitle(searchOrder.title, for: .normal)
        fetchSearch(query)
    }
    
    private func fetchSearch(_ query: String) {
        NetworkManager.shared.request(
            api: .search(query: query, page: 1, order: searchOrder, color: nil),
            model: SearchResponse.self
        ) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let data):
                list = data
                toggleHideView()
                collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        fetchSearch(query)
        view.endEditing(true)
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list?.photoResponse.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.description(), for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        let data = list?.photoResponse[indexPath.item]
        cell.configureCell(data: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(indexPaths)
    }
}
