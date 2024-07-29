//
//  BaseViewController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit
import Toast

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
    
    func makeRealmToast(_ flag: Bool) {
        if flag {
            view.makeToast("저장되었습니다.", duration: 1)
        } else {
            view.makeToast("삭제되었습니다.", duration: 1)
        }
    }
    
    func makeNetworkFailureToast() {
        view.makeToast("네트워크 통신에 실패하였습니다.", duration: 1, position: .center)
    }
}
