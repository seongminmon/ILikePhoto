//
//  TopicViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SnapKit
import Then

final class TopicViewController: BaseViewController {
    
    private lazy var refreshControl = UIRefreshControl()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .createTopicLayout()).then {
        $0.register(
            TopicCollectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TopicCollectionHeaderView.description()
        )
        $0.refreshControl = refreshControl
    }
    
    private enum Section: String, CaseIterable {
        case first, second, third
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, PhotoResponse>!
    
    private let viewModel = TopicViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
    }
    
    override func bindData() {
        let input = TopicViewModel.Input(
            viewDidLoad: Observable.just(()),
            refreshEvent: refreshControl.rx.controlEvent(.valueChanged),
            cellSelected: collectionView.rx.itemSelected
        )
        let output = viewModel.transform(input: input)
        
        output.cellSelected
            .bind(with: self) { owner, value in
                owner.pushDetailViewController(value)
            }
            .disposed(by: disposeBag)
        
        output.remainTime
            .bind(with: self) { owner, value in
                owner.view.makeToast("잠시 후 시도해주세요!", duration: 1, position: .center)
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.networkSuccess
            .bind(with: self) { owner, _ in
                owner.updateSnapshot()
                owner.refreshControl.endRefreshing()
            }
            .disposed(by: disposeBag)
        
        output.networkFailure
            .bind(with: self) { owner, value in
                owner.makeNetworkFailureToast()
            }
            .disposed(by: disposeBag)
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "TOPIC"
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func cellRegistration() -> UICollectionView.CellRegistration<TopicCollectionViewCell, PhotoResponse> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.configureCell(data: itemIdentifier)
        }
    }
    
    private func supplementaryCellRegistration() -> UICollectionView.SupplementaryRegistration<TopicCollectionHeaderView> {
        return UICollectionView.SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            supplementaryView.configureLabel(viewModel.headerTitles[indexPath.section])
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = cellRegistration()
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
            return cell
        })
        
        let supplementaryRegistration = supplementaryCellRegistration()
        dataSource.supplementaryViewProvider = { [weak self] view, kind, index in
            guard let self else { return UICollectionReusableView() }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration,
                for: index
            )
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoResponse>()
        snapshot.appendSections(Section.allCases)
        snapshot.reloadSections(Section.allCases)
        Section.allCases.enumerated().forEach { value in
            snapshot.appendItems(viewModel.list[value.offset], toSection: value.element)
        }
        if #available(iOS 17.0, *) {
            dataSource.apply(snapshot)
        } else {
            dataSource.apply(snapshot, animatingDifferences: false)
        }
//        dataSource.applySnapshotUsingReloadData(snapshot)
    }
}
