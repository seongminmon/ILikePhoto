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
}
