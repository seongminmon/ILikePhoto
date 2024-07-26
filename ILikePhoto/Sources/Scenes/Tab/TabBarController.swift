//
//  TabBarController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        tabBar.tintColor = MyColor.darkgray
        
        let topic = TopicViewController()
        let nav1 = UINavigationController(rootViewController: topic)
        nav1.tabBarItem = UITabBarItem(title: nil, image: MyImage.tapTrendInactive, selectedImage: MyImage.tabTrend)
        
        let random = RandomViewController()
        let nav2 = UINavigationController(rootViewController: random)
        nav2.tabBarItem = UITabBarItem(title: nil, image: MyImage.tabLikeInactive, selectedImage: MyImage.tabLike)
        
        let search = SearchViewController()
        let nav3 = UINavigationController(rootViewController: search)
        nav3.tabBarItem = UITabBarItem(title: nil, image: MyImage.tabSearchInactive, selectedImage: MyImage.tabSearch)
        
        let like = LikeViewController()
        let nav4 = UINavigationController(rootViewController: like)
        nav4.tabBarItem = UITabBarItem(title: nil, image: MyImage.tabRandomInactive, selectedImage: MyImage.tabRandom)
 
        setViewControllers([nav1, nav2, nav3, nav4], animated: true)
        
        tabBar.items?.forEach { $0.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -20, right: 0) }
    }
}

extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
