//
//  ProfileViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

enum ProfileOption: String {
    case create = "PROFILE SETTING"
    case edit = "EDIT PROFILE"
}

final class ProfileViewController: BaseViewController<ProfileView, ProfileViewModel> {
    
    var profileOption = ProfileOption.create
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureNavigationBar() {
        navigationItem.title = profileOption.rawValue
    }
    
    override func configureView() {
        baseView.delegate = self
    }
    
    override func bindData() {
        
    }
    

    @objc func textFieldDidChange() {
        print(#function)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension ProfileViewController: ProfileViewDelegate {
    func profileImageViewTapped() {
        print(#function)
        // TODO: - 프로필 이미지 설정 화면으로 이동하기
    }
    
    func textFieldDidChange(_ text: String) {
        print(#function, text)
    }
    
    func mbtiButtonTapped(_ tag: Int) {
        print(#function, tag)
    }
    
    func confirmButtonTapped() {
        print(#function)
        // TODO: - 유저 정보 저장 && 메인 화면 윈도우 교체
    }
}
