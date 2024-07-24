//
//  BaseTabBarController.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit

final class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = MyColor.darkgray
        
        let topic = TopicViewController()
        let nav1 = UINavigationController(rootViewController: topic)
        nav1.tabBarItem = UITabBarItem(title: nil, image: MyImage.tapTrendInactive, selectedImage: MyImage.tabTrend)
        
        let search = SearchViewController()
        let nav2 = UINavigationController(rootViewController: search)
        nav2.tabBarItem = UITabBarItem(title: nil, image: MyImage.tabSearchInactive, selectedImage: MyImage.tabSearch)
        
        setViewControllers([nav1, nav2], animated: true)
    }
}
