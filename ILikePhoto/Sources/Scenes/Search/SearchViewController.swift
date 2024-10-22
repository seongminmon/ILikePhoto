//
//  SearchViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa
import SnapKit
import Then
import Toast

final class SearchViewController: BaseViewController {
    
    private lazy var searchBar = UISearchBar().then {
        $0.placeholder = "키워드 검색"
    }
    private lazy var colorCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createColorButtonsLayout()
    ).then {
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
        $0.setTitleColor(MyColor.black, for: .normal)
        $0.titleLabel?.font = MyFont.bold14
        $0.tintColor = MyColor.black
        $0.backgroundColor = MyColor.white
        $0.setImage(MyImage.sort, for: .normal)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = MyColor.gray.cgColor
    }
    private lazy var pinterestLayout = PinterestLayout().then {
        $0.delegate = self
    }
    private lazy var mainCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: pinterestLayout
    ).then {
        $0.register(
            SearchCollectionViewCell.self,
            forCellWithReuseIdentifier: SearchCollectionViewCell.description()
        )
        $0.keyboardDismissMode = .onDrag
    }
    private let emptyLabel = UILabel().then {
        $0.font = MyFont.bold20
        $0.textColor = MyColor.black
    }
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindData() {
        
        let likeButtonTap = PublishSubject<PhotoResponse>()
        
        let input = SearchViewModel.Input(
            searchButtonTap: searchBar.rx.searchButtonClicked.asObservable(),
            searchText: searchBar.rx.text.asObservable(),
            sortButtonTap: sortButton.rx.tap.asObservable(),
            colorCellTap: colorCollectionView.rx.itemSelected.asObservable(),
            prefetchItems: mainCollectionView.rx.prefetchItems.asObservable(),
            searchCellTap: mainCollectionView.rx.itemSelected.asObservable(),
            likeButtonTap: likeButtonTap
        )
        let output = viewModel.transform(input: input)
        
        output.searchOrder
            .map { $0.title }
            .bind(to: sortButton.rx.title())
            .disposed(by: disposeBag)
        
        output.colorList
            .bind(to: colorCollectionView.rx.items(
                cellIdentifier: ColorCollectionViewCell.description(),
                cellType: ColorCollectionViewCell.self
            )) { [weak self] index, color, cell in
                cell.configureCell(color: color)
                cell.toggleSelected(isSelect: color == self?.viewModel.searchParameter.color)
            }
            .disposed(by: disposeBag)
        
        output.searchList
            .bind(to: mainCollectionView.rx.items(
                cellIdentifier: SearchCollectionViewCell.description(),
                cellType: SearchCollectionViewCell.self
            )) { index, element, cell in
                cell.configureCell(data: element)
                cell.likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(element.id) != nil)
                
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        likeButtonTap.onNext(element)
                        cell.likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(element.id) != nil)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.emptyText
            .bind(to: emptyLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.emptyQuery
            .bind(with: self) { owner, _ in
                owner.view.makeToast("쿼리가 비었습니다!", duration: 1, position: .center)
            }
            .disposed(by: disposeBag)
        
        output.emptyResponse
            .bind(to: mainCollectionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.emptyResponse
            .map { !$0 }
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.scrollToTop
            .subscribe(with: self) { owner, _ in
                owner.mainCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
            .disposed(by: disposeBag)
        
        output.searchCellTap
            .bind(with: self) { owner, data in
                owner.pushDetailViewController(data)
            }
            .disposed(by: disposeBag)
        
        output.likeButtonTap
            .bind(with: self) { owner, isLike in
                owner.makeRealmToast(isLike)
            }
            .disposed(by: disposeBag)
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
}

extension SearchViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        guard let data = viewModel.searchResponse?.photoResponse[indexPath.item] else { return 180 }
        let ratio = CGFloat(data.height) / CGFloat(data.width)
        let width = view.frame.width / 2
        return width * ratio
    }
}
