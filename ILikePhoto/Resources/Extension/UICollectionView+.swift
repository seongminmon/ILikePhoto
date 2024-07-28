//
//  UICollectionView+.swift
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
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
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

//class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
//    let cellSpacing: CGFloat = 10
// 
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        self.minimumLineSpacing = 10.0
//        self.sectionInset = UIEdgeInsets(top: 12.0, left: 16.0, bottom: 0.0, right: 16.0)
//        let attributes = super.layoutAttributesForElements(in: rect)
// 
//        var leftMargin = sectionInset.left
//        var maxY: CGFloat = -1.0
//        attributes?.forEach { layoutAttribute in
//            if layoutAttribute.frame.origin.y >= maxY {
//                leftMargin = sectionInset.left
//            }
//            layoutAttribute.frame.origin.x = leftMargin
//            leftMargin += layoutAttribute.frame.width + cellSpacing
//            maxY = max(layoutAttribute.frame.maxY, maxY)
//        }
//        return attributes
//    }
//}
