//
//  Image.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit

enum MyImage {
    static let profileImageList: [UIImage] = [
        UIImage(named: "profile_0")!,
        UIImage(named: "profile_1")!,
        UIImage(named: "profile_2")!,
        UIImage(named: "profile_3")!,
        UIImage(named: "profile_4")!,
        UIImage(named: "profile_5")!,
        UIImage(named: "profile_6")!,
        UIImage(named: "profile_7")!,
        UIImage(named: "profile_8")!,
        UIImage(named: "profile_9")!,
        UIImage(named: "profile_10")!,
        UIImage(named: "profile_11")!,
    ]
    
    static let launch = UIImage(named: "launch")!
    static let launchLogoImage = UIImage(named: "launchLogoImage")!
    static let likeCircleInactive = UIImage(named: "like_circle_inactive")!
    static let likeCircle = UIImage(named: "like_circle")!
    static let likeInactive = UIImage(named: "like_inactive")!
    static let like = UIImage(named: "like")!
    static let sort = UIImage(named: "sort")!
    static let tabLikeInactive = UIImage(named: "tab_like_inactive")!
    static let tabLike = UIImage(named: "tab_like")!
    static let tabRandomInactive = UIImage(named: "tab_random_inactive")!
    static let tabRandom = UIImage(named: "tab_random")!
    static let tabSearchInactive = UIImage(named: "tab_search_inactive")!
    static let tabSearch = UIImage(named: "tab_search")!
    static let tabTrend = UIImage(named: "tab_trend")!
    static let tapTrendInactive = UIImage(named: "tap_trend_inactive")!
    
    static let camera = UIImage(systemName: "camera.fill")!
    static let star = UIImage(systemName: "star.fill")!
    static let circle = UIImage(systemName: "circle.fill")!.withRenderingMode(.alwaysTemplate)
}
