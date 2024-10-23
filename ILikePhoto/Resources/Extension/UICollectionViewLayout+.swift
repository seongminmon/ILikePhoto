//
//  UICollectionViewLayout+.swift
//  ILikePhoto
//
//  Created by 김성민 on 7/22/24.
//

import UIKit

extension UICollectionViewLayout {
    
    // 높이 비율
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
    
    // 높이 고정
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
    
    static func createMBTILayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 40, height: 40)
        let spacing: CGFloat = 10
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        return layout
    }
    
    static func createColorButtonsLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let spacing: CGFloat = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
        return layout
    }
    
    static func createTopicLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .fractionalWidth(0.8 * 3 / 4)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.supplementariesFollowContentInsets = false
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44))
        let headerSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        headerSupplementary.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [headerSupplementary]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat
}

final class PinterestLayout: UICollectionViewLayout {
    
    weak var delegate: PinterestLayoutDelegate?
    
    private var numberOfColumns: Int = 2
    private var cellPadding: CGFloat = 1.0
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0.0
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0.0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        print(#function)
        print("캐시 카운트", cache.count)
        
        super.prepare()
        guard let collectionView = collectionView else { return }
        cache.removeAll()
        
        // xOffset 계산
        let width: CGFloat = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            let offset = CGFloat(column) * width
            xOffset.append(offset)
        }
        
        // yOffset 계산
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let imageHeight = delegate?.collectionView(collectionView, heightForImageAtIndexPath: indexPath) ?? 0
            let height = cellPadding * 2 + imageHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // cache 저장
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 새로 계산된 항목의 프레임을 설명하도록 확장
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            // 다음 항목이 다음 열에 배치되도록 설정
            column = column < numberOfColumns - 1 ? column + 1 : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { rect.intersects($0.frame) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
