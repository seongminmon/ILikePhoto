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
        
        tabBar.tintColor = Design.Color.darkgray
        
        let topic = TopicViewController()
        let nav1 = UINavigationController(rootViewController: topic)
        nav1.tabBarItem = UITabBarItem(title: nil, image: Design.Image.tapTrendInactive, selectedImage: Design.Image.tabTrend)
        
        setViewControllers([nav1], animated: true)
    }
}
