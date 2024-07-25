//
//  SceneDelegate.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let repository = RealmRepository()
        print(repository.fileURL)
        print(repository.schemaVersion)
        
        if UserDefaultsManager.signUpDate == nil {
            let vc = OnboardingViewController()
            let nav = UINavigationController(rootViewController: vc)
            window?.rootViewController = nav
        } else {
            let tab = BaseTabBarController()
            window?.rootViewController = tab
        }
        window?.backgroundColor = MyColor.white
        window?.makeKeyAndVisible()
    }
}
