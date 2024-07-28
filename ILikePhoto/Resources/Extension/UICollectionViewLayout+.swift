//
//  UICollectionViewLayout+.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

extension UICollectionViewLayout {
    static func createLayout(spacing: CGFloat, cellCount: CGFloat, aspectRatio: CGFloat) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - (2 * spacing) - ((cellCount-1) * spacing)
        layout.itemSize = CGSize(width: width / cellCount, height: width / cellCount * aspectRatio)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        return layout
    }
    
    static func createHorizontalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let spacing: CGFloat = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        return layout
    }
    
    static func createLayout(spacing: CGFloat, cellCount: CGFloat, height: CGFloat) -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width - (2 * spacing) - ((cellCount-1) * spacing)
        layout.itemSize = CGSize(width: width / cellCount, height: height)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        return layout
    }
}
