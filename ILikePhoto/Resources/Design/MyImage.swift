//
//  Image.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/24/24.
//

import UIKit
import SwiftUI

enum MyImage {
    static let profileImageList: [UIImage] = [
        UIImage(resource: .profile0),
        UIImage(resource: .profile1),
        UIImage(resource: .profile2),
        UIImage(resource: .profile3),
        UIImage(resource: .profile4),
        UIImage(resource: .profile5),
        UIImage(resource: .profile6),
        UIImage(resource: .profile7),
        UIImage(resource: .profile8),
        UIImage(resource: .profile9),
        UIImage(resource: .profile10),
        UIImage(resource: .profile11)
    ]
    
    static let launch = UIImage(resource: .launch)
    static let launchLogoImage = UIImage(resource: .launchLogo)
    static let likeCircleInactive = UIImage(resource: .likeCircleInactive)
    static let likeCircle = UIImage(resource: .likeCircle)
    static let likeInactive = UIImage(resource: .likeInactive)
    static let like = UIImage(resource: .like)
    static let sort = UIImage(resource: .sort)
    static let tabLikeInactive = UIImage(resource: .tabLikeInactive)
    static let tabLike = UIImage(resource: .tabLike)
    static let tabRandomInactive = UIImage(resource: .tabRandomInactive)
    static let tabRandom = UIImage(resource: .tabRandom)
    static let tabSearchInactive = UIImage(resource: .tabSearchInactive)
    static let tabSearch = UIImage(resource: .tabSearch)
    static let tabTrend = UIImage(resource: .tabTrend)
    static let tapTrendInactive = UIImage(resource: .tapTrendInactive)
    
    static let camera = UIImage(systemName: "camera.fill")!
    static let star = UIImage(systemName: "star.fill")!
    static let circle = UIImage(systemName: "circle.fill")!.withRenderingMode(.alwaysTemplate)
}
