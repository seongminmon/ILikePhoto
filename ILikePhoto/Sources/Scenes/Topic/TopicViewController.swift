//
//  TopicViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import SnapKit
import Then

final class TopicViewController: BaseViewController {
    // TODO: - refresh control이 애니메이션 중 깜박거리는 문제 해결하기
    // TODO: - 새로 고침 후 1분이 지나지 않았으면 통신하지 않도록 만들기
    
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    private lazy var profileImageView = ProfileImageView().then {
        $0.setImageView(isSelect: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingButtonTapped))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
    }
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.delegate = self
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
    
    private var headerTitles = [String](repeating: "", count: Section.allCases.count)
    private var list = [[PhotoResponse]](repeating: [], count: Section.allCases.count)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        fetchTopic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        profileImageView.image = MyImage.profileImageList[UserDefaultsManager.profileImageIndex]
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "OUR TOPIC"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    override func configureHierarchy() {
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    @objc private func settingButtonTapped() {
        let vc = SettingNicknameViewController()
        vc.option = .edit
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.45),
            heightDimension: .fractionalWidth(0.45 * 4 / 3)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        // 수평 스크롤
        section.orthogonalScrollingBehavior = .continuous
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerSupplementary]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func cellRegistration() -> UICollectionView.CellRegistration<TopicCollectionViewCell, PhotoResponse> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.configureCell(data: itemIdentifier)
        }
    }
    
    private func supplementaryCellRegistration() -> UICollectionView.SupplementaryRegistration<TopicCollectionHeaderView> {
        return UICollectionView.SupplementaryRegistration(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, elementKind, indexPath in
            supplementaryView.configureLabel(self.headerTitles[indexPath.section])
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
        snapshot.appendItems(list[0], toSection: .first)
        snapshot.appendItems(list[1], toSection: .second)
        snapshot.appendItems(list[2], toSection: .third)
        dataSource.apply(snapshot)
    }
    
    private func fetchTopic() {
        // 토픽 3개 뽑기 (랜덤, 중복 X)
        var topicIDList = [String]()
        while topicIDList.count < Section.allCases.count {
            let topicID = TopicIDQuery.list.keys.randomElement() ?? "golden-hour"
            if !topicIDList.contains(topicID) {
                topicIDList.append(topicID)
            }
        }
        
        let dispatchGroup = DispatchGroup()
        
        // 3번 통신하기
        for i in 0..<Section.allCases.count {
            let topicID = topicIDList[i]
            dispatchGroup.enter()
            NetworkManager.shared.request(
                api: .topic(topicID: topicID), model: [PhotoResponse].self
            ) { [weak self] response in
                guard let self else { return }
                switch response {
                case .success(let data):
                    headerTitles[i] = TopicIDQuery.list[topicID] ?? "골든 아워"
                    list[i] = data
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateSnapshot()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @objc private func refresh() {
        fetchTopic()
    }
}

extension TopicViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = list[indexPath.section][indexPath.item]
        pushDetailViewController(data)
    }
}
