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
//        $0.image = MyImage.profileImageList[UserDefaultsManager.profileImageIndex]
        $0.setImageView(isSelect: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(settingButtonTapped))
        $0.addGestureRecognizer(tapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = true
        profileImageView.image = MyImage.profileImageList[UserDefaultsManager.profileImageIndex]
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "OUR TOPIC"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    
    override func configureHierarchy() {
        
    }
    
    override func configureLayout() {
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(40)
        }
    }
    
    override func configureView() {
        
    }
    
    @objc func settingButtonTapped() {
        // TODO: - 이동할때 탭바 숨기기
        let vc = SettingNicknameViewController()
        vc.option = .edit
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
