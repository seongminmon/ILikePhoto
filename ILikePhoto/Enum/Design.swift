//
//  Design.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

enum Design {
    
    enum Image {
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
    }
    
    enum Font {
        static let title = UIFont.boldSystemFont(ofSize: 30)
        
        static let bold20 = UIFont.boldSystemFont(ofSize: 20)
        static let bold16 = UIFont.boldSystemFont(ofSize: 16)
        static let bold15 = UIFont.boldSystemFont(ofSize: 15)
        static let bold14 = UIFont.boldSystemFont(ofSize: 14)
        static let bold13 = UIFont.boldSystemFont(ofSize: 13)
        
        static let regular16 = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let regular15 = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let regular14 = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let regular13 = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    enum Color {
        static let blue = UIColor.hexStringToUIColor("186FF2")
        static let gray = UIColor.hexStringToUIColor("8C8C8C")
        static let darkgray = UIColor.hexStringToUIColor("4D5652")
        static let black = UIColor.hexStringToUIColor("000000")
        static let lightgray = UIColor.hexStringToUIColor("F2F2F2")
        static let white = UIColor.hexStringToUIColor("FFFFFF")
        static let red = UIColor.hexStringToUIColor("F04452")
    }
}
