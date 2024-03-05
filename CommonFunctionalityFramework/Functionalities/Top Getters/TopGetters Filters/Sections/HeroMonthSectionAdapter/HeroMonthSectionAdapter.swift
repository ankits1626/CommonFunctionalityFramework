//
//  HeroMonthSectionAdapter.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation
import UIKit

class HeroMonthSectionAdapter : BaseFilterSectionAdapter,  TopGettersSectionProtocol {
    
    func heightOfHeader(_ collectionView : UICollectionView) -> CGSize {
        if let count = filterCoordinator?.heroOptions.count{
            return count > 0 ? CGSize(width: collectionView.frame.size.width, height: 50) : .zero
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
            headerView.frame.size.height = count > 0 ? 50 : 0
        }else{
            headerView.frame.size.height = 0
        }
        headerView.backgroundColor = .white
        headerView.titleView?.backgroundColor = .clear
        headerView.actionButtonView?.backgroundColor = .clear
        headerView.title?.text = "Heroes".localized
        headerView.actionButtonWidth?.constant = 80
        headerView.actionButton?.isHidden = false
        headerView.actionButton?.tintColor = .gray
        headerView.actionButton?.setImage(
            UIImage(
                named: self.filterCoordinator!.isHeroExpanded ? "cff_collapseIcon"  : "cff_expandIcon",
                in: Bundle(for: RecognitionSecionAdapter.self),
                compatibleWith: nil),
            for: .normal
        )
        headerView.actionButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
            self.filterCoordinator?.isHeroExpanded = !self.filterCoordinator!.isHeroExpanded
            collectionView.reloadData()
        })
        return headerView
    }
    
    func registerCellAndHeader(_ collectionView: UICollectionView?) {
        collectionView?.register(
            UINib(nibName: "BubbleOptionCollectionViewCell", bundle: Bundle(for: BubbleOptionCollectionViewCell.self)),
            forCellWithReuseIdentifier: "BubbleOptionCollectionViewCell"
        )
        collectionView?.register(
            UINib(nibName: "TopGettersFilterHeader", bundle: Bundle(for: TopGettersFilterHeader.self)),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "TopGettersFilterHeader")
    }
    
    func getNumberOfItemsInSection() -> Int {
        if let exapendNeeded = self.filterCoordinator?.isHeroExpanded {
            return exapendNeeded == true ? filterCoordinator?.heroOptions.count ?? 0 : 0
        }
        return 0
    }
    
    func getCell(_ collectionView: UICollectionView, indexpath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BubbleOptionCollectionViewCell",
            for: indexpath) as? BubbleOptionCollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        configureCell(cell: cell, index: indexpath.item)
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, index: Int) {
        if let filterOption =  filterCoordinator?.heroOptions[safe: index],
            let bubbleOptionCell = cell as? BubbleOptionCollectionViewCell {
            bubbleOptionCell.titleLabel?.text = filterOption.displayName
            bubbleOptionCell.titleLabel?.textColor = filterCoordinator?.isHeroOptionSelected(index) ?? false ? .white : .black
            bubbleOptionCell.selectionIndicator?.backgroundColor = filterCoordinator?.isHeroOptionSelected(index) ?? false ? UIColor.getControlColor() : .white
            cell.contentView.curvedWithoutBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255), borderWidth: 1, cornerRadius: 8)
            cell.contentView.layer.borderWidth = filterCoordinator?.isHeroOptionSelected(index) ?? false ? 0 : 1.0
        }
    }
}


