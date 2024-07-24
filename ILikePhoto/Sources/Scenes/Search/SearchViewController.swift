//
//  SearchViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import SnapKit
import Then

final class SearchViewController: BaseViewController {
    
    private lazy var searchBar = UISearchBar().then {
        $0.placeholder = "키워드 검색"
        $0.delegate = self
    }
    private lazy var sortButton = UIButton().then {
        $0.setTitle("최신순", for: .normal)
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
        $0.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.description())
        $0.keyboardDismissMode = .onDrag
    }
    
    var list = [PhotoResponse]()
    var page = 1
    var searchOrder = SearchOrder.relevant
//    var searchColor: SearchColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "SEARCH PHOTO"
    }
    
    override func configureHierarchy() {
        [searchBar, sortButton, collectionView].forEach {
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
    }
    
    override func configureView() {
    }
    
    @objc private func sortButtonTapped() {
        print(#function)
    }
    
    private func fetchSearch(_ query: String) {
        NetworkManager.shared.request(api: .search(query: query, page: 1, order: .relevant, color: nil), model: [PhotoResponse].self) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let data):
                list = data
                collectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        print(searchText)
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
        // TODO: - query 유효성 검사
        guard let query = searchBar.text else { return }
        fetchSearch(query)
        view.endEditing(true)
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.description(), for: indexPath) as? PhotoCollectionViewCell else { return UICollectionViewCell() }
        let data = list[indexPath.item]
        cell.configureCell(data: data)
        return cell
    }
}
