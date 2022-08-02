//
//  MultipleImageFlowLayout.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 01/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

protocol MultipleImageFlowLayoutDelegate {
    func currentPageSelected(currentPage : Int)
}

class MultipleImageFlowLayout: UICollectionViewFlowLayout {

    var previousOffset : CGFloat = 0
    var currentPage : CGFloat = 0
    var addLeadingSpace : CGFloat = 0
    var pageCollectionLayoutDelegate : MultipleImageFlowLayoutDelegate?
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let sup = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        guard
            let validCollection = collectionView,
            let dataSource = validCollection.dataSource
            else { return sup }
        let itemsCount = dataSource.collectionView(validCollection, numberOfItemsInSection: 0)
        // Imitating paging behaviour
        // Check previous offset and scroll direction
        if  (previousOffset > validCollection.contentOffset.x) && (velocity.x < 0) {
            currentPage = max(currentPage - 1, 0)
        }
        else if (previousOffset < validCollection.contentOffset.x) && (velocity.x > 0) {
            currentPage = min(currentPage + 1, CGFloat(itemsCount - 1))
        }
        let updatedOffset : CGFloat = (currentPage) * (UIScreen.main.bounds.size.width - 34)
        self.previousOffset = updatedOffset
        let updatedPoint = CGPoint(x: updatedOffset, y: proposedContentOffset.y)
        self.pageCollectionLayoutDelegate?.currentPageSelected(currentPage: Int(currentPage))
        return updatedPoint
    }
}


