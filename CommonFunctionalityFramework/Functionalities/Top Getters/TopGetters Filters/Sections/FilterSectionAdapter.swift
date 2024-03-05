//
//  FilterSectionAdapter.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation
import UIKit

enum TopGettersFilterSection : Int, CaseIterable {
    case RecognitionType = 0
    case RecognitionTypeSeparator
    case HeroFilter
    case HeroFilterSeparator
    
    func getAdapter(_ coordinator : TopGettersFilterCoordinator) -> TopGettersSectionProtocol {
        switch self {
        case .RecognitionType:
            return RecognitionSecionAdapter(filterCoordinator: coordinator)
        case .RecognitionTypeSeparator:
            return RecognitionSeparator(filterCoordinator: coordinator)
        case .HeroFilter:
            return HeroMonthSectionAdapter(filterCoordinator: coordinator)
        case .HeroFilterSeparator:
            return HeroMonthSeparator(filterCoordinator: coordinator)
        }
    }
}

protocol TopGettersSectionProtocol {
    func registerCellAndHeader(_ collectionView: UICollectionView?)
    func getNumberOfItemsInSection() -> Int
    func getCell(_ collectionView: UICollectionView, indexpath : IndexPath) -> UICollectionViewCell
    func getHeader(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    func configureCell(cell : UICollectionViewCell, index : Int)
    func heightOfHeader(_ collectionView : UICollectionView) -> CGSize
}

class BaseFilterSectionAdapter {
    weak var filterCoordinator: TopGettersFilterCoordinator?
    
    init(filterCoordinator : TopGettersFilterCoordinator) {
        self.filterCoordinator = filterCoordinator
    }
}

