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
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        
        let tab = TabBarController()
        window.rootViewController = tab
        window.makeKeyAndVisible()
        
        UIView.transition(
            with: window,
            duration: 0.2,
            options: [.transitionCrossDissolve],
            animations: nil,
            completion: nil
        )
    }
    
    func changeWindowToOnboarding() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else { return }
        
        let vc = OnboardingViewController()
        let nav = UINavigationController(rootViewController: vc)
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
        UIView.transition(
            with: window,
            duration: 0.2,
            options: [.transitionCrossDissolve],
            animations: nil,
            completion: nil
        )
    }
    
    func pushDetailViewController(_ data: PhotoResponse?) {
        let vc = DetailViewController()
        vc.viewModel.outputPhoto.value = data
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showDeleteAlert(
        completionHandler: @escaping (UIAlertAction) -> Void
    ) {
        let alert = UIAlertController(
            title: "탈퇴하기",
            message: "탈퇴를 하면 데이터가 모두 초기화됩니다. 탈퇴하시겠습니까?",
            preferredStyle: .alert
        )
        let delete = UIAlertAction(title: "탈퇴", style: .destructive, handler: completionHandler)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addAction(delete)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
//    func showActionSheet(
//        firstTitle: String,
//        secondTitle: String,
//        firstHandler: @escaping (UIAlertAction) -> Void,
//        secondHandler: @escaping (UIAlertAction) -> Void,
//    ) {
//        let alert = UIAlertController(
//            title: nil,
//            message: nil,
//            preferredStyle: .actionSheet
//        )
//        let first = UIAlertAction(title: firstTitle, style: .default, handler: firstHandler)
//        let second = UIAlertAction(title: secondTitle, style: .default, handler: secondHandler)
//        alert.addAction(first)
//        alert.addAction(second)
//        present(alert, animated: true)
//    }
}
