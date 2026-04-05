//
//  PinterestLike.swift
//  luchit22Notes
//
//  Created by lukss on 13.01.26.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {

    weak var delegate: PinterestLayoutDelegate?

    private let numcols = 2
    private let cell: CGFloat = 8
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var cheight: CGFloat = 0
    private var cwidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let inset = collectionView.contentInset
        return collectionView.bounds.width - (inset.left + inset.right)
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: cwidth, height: cheight)
    }

    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else { return }

        let columnWidth = cwidth / CGFloat(numcols)
        var xOffset: [CGFloat] = []
        for column in 0..<numcols {
            xOffset.append(CGFloat(column) * columnWidth)
        }

        var column = 0
        var yOffset: [CGFloat] = Array(repeating: 0, count: numcols)

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            let width = columnWidth - cell * 2
            let textHeight = delegate?.collectionView(collectionView, heightForTextAtIndexPath: indexPath, width: width) ?? 50
            let height = textHeight + (cell * 2) + 20

            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cell, dy: cell)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)

            cheight = max(cheight, frame.maxY)
            yOffset[column] += height
            
            column = yOffset.firstIndex(of: yOffset.min() ?? 0) ?? 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache[indexPath.item]
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        cheight = 0
    }
}
