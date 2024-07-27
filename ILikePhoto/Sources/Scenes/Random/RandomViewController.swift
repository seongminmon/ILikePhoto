//
//  RandomViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/26/24.
//

import UIKit
import SnapKit
import Then

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
        // 스크롤이 빠르게 되도록 (페이징 애니메이션같이 보이게하기 위함)
//        $0.decelerationRate = .fast
    }
    
    var list = [PhotoResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.shared.request(api: .random, model: [PhotoResponse].self) { [weak self] response in
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
    
    // 네비게이션바 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func configureNavigationBar() {
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
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RandomCollectionViewCell.description(),
            for: indexPath
        ) as? RandomCollectionViewCell else {
            return UICollectionViewCell()
        }
        let data = list[indexPath.row]
        cell.configureCell(data, page: indexPath.row)
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // 탭바 높이만큼 스크롤 내려주기
        // 탭바 높이 가져오기
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        
        // 현재 콘텐츠 오프셋
        var targetOffset = targetContentOffset.pointee
        
        // 새로운 오프셋 계산 (탭바 높이만큼 내리기)
        targetOffset.y += tabBarHeight
        
        // 새로운 오프셋이 콘텐츠 높이를 넘지 않도록 조정
        let maxOffsetY = scrollView.contentSize.height - scrollView.frame.size.height
        targetOffset.y = min(targetOffset.y, maxOffsetY)
        
        // 타겟 오프셋 설정
        targetContentOffset.pointee = targetOffset
    }
}
