//
//  HeroMonthSeparator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation
import UIKit
import RewardzCommonComponents

class HeroMonthSeparator : BaseFilterSectionAdapter,  TopGettersSectionProtocol {
        
    func heightOfHeader(_ collectionView : UICollectionView) -> CGSize {
        if let count = filterCoordinator?.heroOptions.count{
            return count > 0 ? CGSize(width: collectionView.frame.size.width, height: 1) : .zero
        }else{
            return .zero
        }
    }
    
    func getHeader(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "TopGettersFilterHeader",
            for: indexPath) as! TopGettersFilterHeader

        if let count = filterCoordinator?.heroOptions.count{
            headerView.frame.size.height = count > 0 ? 1 : 0
        }else{
            headerView.frame.size.height = 0
        }
        headerView.backgroundColor = Rgbconverter.HexToColor("#EDF0FF")
        headerView.titleView?.backgroundColor = Rgbconverter.HexToColor("#EDF0FF")
        headerView.actionButtonView?.backgroundColor = Rgbconverter.HexToColor("#EDF0FF")
        headerView.title?.text = ""
        headerView.actionButton?.isHidden = true
        headerView.actionButtonWidth?.constant = 0
        return headerView
    }
    
    
    
    func registerCellAndHeader(_ collectionView: UICollectionView?) {
        collectionView?.register(
            UINib(nibName: "TopGettersSeparatorCollectionViewCell", bundle: Bundle(for: TopGettersSeparatorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "TopGettersSeparatorCollectionViewCell"
        )
        collectionView?.register(
            UINib(nibName: "TopGettersFilterHeader", bundle: Bundle(for: TopGettersFilterHeader.self)),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "TopGettersFilterHeader")
    }
    
    func getNumberOfItemsInSection() -> Int {
        return 0
    }
    
    func getCell(_ collectionView: UICollectionView, indexpath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "TopGettersSeparatorCollectionViewCell",
            for: indexpath) as? TopGettersSeparatorCollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        configureCell(cell: cell, index: indexpath.item)
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, index: Int) {
        //
    }
    
    
}





