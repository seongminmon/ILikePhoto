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
        
        tabBar.tintColor = MyColor.darkgray
        
        let topic = TopicViewController()
        let nav1 = UINavigationController(rootViewController: topic)
        nav1.tabBarItem = UITabBarItem(title: nil, image: MyImage.tapTrendInactive, selectedImage: MyImage.tabTrend)
        
        let search = SearchViewController()
        let nav2 = UINavigationController(rootViewController: search)
        nav2.tabBarItem = UITabBarItem(title: nil, image: MyImage.tabSearchInactive, selectedImage: MyImage.tabSearch)
        
        let like = LikeViewController()
        let nav3 = UINavigationController(rootViewController: like)
        nav3.tabBarItem = UITabBarItem(title: nil, image: MyImage.tabLikeInactive, selectedImage: MyImage.tabLike)
        
        setViewControllers([nav1, nav2, nav3], animated: true)
    }
}
