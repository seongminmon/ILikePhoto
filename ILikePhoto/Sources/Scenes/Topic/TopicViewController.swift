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
    
    private lazy var profileImageView = ProfileImageView().then {
        $0.setImageView(isSelect: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingButtonTapped))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
    
    enum Section: String, CaseIterable {
        case first, second, third
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, PhotoResponse>!
    
    var list = [[PhotoResponse]](repeating: [], count: Section.allCases.count)
    
    let naviTitle = "OUR TOPIC"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDataSource()
        updateSnapshot()
        fetchTopic()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        profileImageView.image = MyImage.profileImageList[UserDefaultsManager.profileImageIndex]
    }
    
    override func configureNavigationBar() {
        navigationItem.title = naviTitle
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
    
    override func configureView() {
        collectionView.backgroundColor = MyColor.blue
    }
    
    @objc func settingButtonTapped() {
        let vc = SettingNicknameViewController()
        vc.option = .edit
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func topicCellRegistration() -> UICollectionView.CellRegistration<TopicCollectionViewCell, PhotoResponse> {
        return UICollectionView.CellRegistration { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier.urls.small)
            cell.backgroundColor = MyColor.gray
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = topicCellRegistration()
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
            return cell
        })
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoResponse>()
        snapshot.appendSections(Section.allCases)
        snapshot.appendItems(list[0], toSection: .first)
        snapshot.appendItems(list[1], toSection: .second)
        snapshot.appendItems(list[2], toSection: .third)
        dataSource.apply(snapshot)
    }
    
    private func fetchTopic() {
        for i in 0..<Section.allCases.count {
            let topicID = TopicIDQuery.list.keys.randomElement() ?? "golden-hour"
            NetworkManager.shared.request(api: .topic(topicID: topicID), model: [PhotoResponse].self) { response in
                switch response {
                case .success(let data):
                    print("SUCCESS", topicID, data.count)
                    self.list[i] = data
                    self.updateSnapshot()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
}
