//
//  RandomViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
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
        $0.delegate = self
        $0.dataSource = self
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
        viewModel.inputViewDidLoad.value = ()
    }
    
    override func bindData() {
        viewModel.outputList.bind { [weak self] list in
            guard let self else { return }
            collectionView.reloadData()
        }
        
        viewModel.outputButtonToggle.bind { [weak self] value in
            guard let self else { return }
            if value {
                view.makeToast("저장되었습니다")
            } else {
                view.makeToast("삭제되었습니다")
            }
            collectionView.reloadData()
        }
    }
    
    // 네비게이션바 숨기기
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

extension RandomViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.outputList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RandomCollectionViewCell.description(),
            for: indexPath
        ) as? RandomCollectionViewCell else {
            return UICollectionViewCell()
        }
        let data = viewModel.outputList.value[indexPath.row]
        cell.configureCell(data, page: indexPath.row)
        
        cell.likeButton.toggleButton(isLike: RealmRepository.shared.fetchItem(data.id) != nil)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc private func likeButtonTapped(sender: UIButton) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: sender.tag, section: 0)) as? RandomCollectionViewCell else { return }
        viewModel.inputLikeButtonTap.value = (sender.tag, cell.mainImageView.image)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.outputList.value[indexPath.item]
        pushDetailViewController(data)
    }
}
