//
//  RandomViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import Toast

final class RandomViewController: BaseViewController {
    
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createLayout(
            spacing: 0,
            cellCount: 1,
            height: view.bounds.height)
    ).then {
        $0.register(
            RandomCollectionViewCell.self,
            forCellWithReuseIdentifier: RandomCollectionViewCell.description()
        )
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.isPagingEnabled = true
        $0.contentInsetAdjustmentBehavior = .never
        $0.decelerationRate = .fast
    }
    
    private let viewModel = RandomViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bindData() {
        
        let likeTap = PublishSubject<Int>()
        
        let input = RandomViewModel.Input(
            viewDidLoad: Observable.just(()),
            cellTap: collectionView.rx.itemSelected,
            likeTap: likeTap
        )
        let output = viewModel.transform(input: input)
        
        output.list
            .bind(to: collectionView.rx.items(
                cellIdentifier: RandomCollectionViewCell.description(),
                cellType: RandomCollectionViewCell.self
            )) { (row, element, cell) in
                cell.configureCell(element, page: row)
                cell.likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(element.id) != nil)
                
                cell.likeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        likeTap.onNext(row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.cellTap
            .subscribe(with: self) { owner, value in
                owner.pushDetailViewController(value)
            }
            .disposed(by: disposeBag)
        
        output.likeTap
            .subscribe(with: self) { owner, value in
                owner.makeRealmToast(value)
                owner.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .subscribe(with: self) { owner, value in
                owner.makeNetworkFailureToast()
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
