//
//  SelectImageViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/23/24.
//

import UIKit
import SnapKit
import Then

final class SelectImageViewController: BaseViewController {
    
    private lazy var selectedImageView = ProfileImageView().then {
        $0.image = MyImage.profileImageList[selectedIndex ?? 0]
        $0.setImageView(isSelect: true)
    }
    private let cameraImageView = CameraImageView(frame: .zero)
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createLayout(spacing: 10, cellCount: 4, aspectRatio: 1)
    ).then {
        $0.delegate = self
        $0.dataSource = self
        $0.register(
            SelectImageCollectionViewCell.self, 
            forCellWithReuseIdentifier: SelectImageCollectionViewCell.description()
        )
    }
    
    // 이전 화면에서 전달
    var option: ProfileOption?
    var selectedIndex: Int?
    // 역값 전달
    var sendSelectedIndex: ((Int) -> Void)?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sendSelectedIndex?(selectedIndex ?? 0)
    }
    
    override func configureNavigationBar() {
        navigationItem.title = option?.rawValue
    }
    
    override func configureHierarchy() {
        view.addSubview(selectedImageView)
        view.addSubview(cameraImageView)
        view.addSubview(collectionView)
    }
    
    override func configureLayout() {
        selectedImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }
        
        cameraImageView.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(selectedImageView)
            make.size.equalTo(50)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(selectedImageView.snp.bottom).offset(40)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SelectImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MyImage.profileImageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectImageCollectionViewCell.description(),
            for: indexPath
        ) as? SelectImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(index: indexPath.item, selectedIndex: selectedIndex ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        selectedImageView.image = MyImage.profileImageList[indexPath.item]
        collectionView.reloadData()
    }
}
