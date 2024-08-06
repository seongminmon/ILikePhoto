//
//  SettingImageViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class SettingImageViewController: BaseViewController {
    
    private lazy var selectedImageView = ProfileImageView().then {
        $0.image = MyImage.profileImageList[selectedIndex ?? 0]
        $0.setImageView(isSelect: true)
    }
    private let cameraImageView = CameraImageView(frame: .zero)
    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: .createLayout(spacing: 10, cellCount: 4, aspectRatio: 1)
    ).then {
        $0.register(
            SettingImageCollectionViewCell.self, 
            forCellWithReuseIdentifier: SettingImageCollectionViewCell.description()
        )
    }
    
//    private let viewModel = SettingImageViewModel()
    
    // 이전 화면에서 전달
    var option: SettingOption?
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
        [
            selectedImageView,
            cameraImageView,
            collectionView
        ].forEach {
            view.addSubview($0)
        }
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
    
    override func bindData() {
//        let input = SettingImageViewModel.Input()
//        let output = viewModel.transform(input: input)
        
        BehaviorRelay(value: MyImage.profileImageList)
            .bind(to: collectionView.rx.items(
                cellIdentifier: SettingImageCollectionViewCell.description(),
                cellType: SettingImageCollectionViewCell.self
            )) { item, element, cell in
                cell.configureCell(index: item, selectedIndex: self.selectedIndex ?? 0)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                owner.selectedIndex = indexPath.item
                owner.selectedImageView.image = MyImage.profileImageList[indexPath.item]
                owner.collectionView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}
