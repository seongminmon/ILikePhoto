//
//  BaseViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = MyColor.black
        navigationItem.backButtonDisplayMode = .minimal
        view.backgroundColor = MyColor.white
        
        configureNavigationBar()
        configureHierarchy()
        configureLayout()
        configureView()
        bindData()
    }
    
    func configureNavigationBar() {}
    func configureHierarchy() {}
    func configureLayout() {}
    func configureView() {}
    func bindData() {}
}

extension BaseViewController {
    func changeWindowToTabBarController() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        
        let tab = BaseTabBarController()
        sceneDelegate?.window?.rootViewController = tab
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}
