//
//  MultipleMediaTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class MultipleMediaTableViewCellCoordinator :  FeedCellCoordinatorProtocol,MultipleImageFlowLayoutDelegate{
    
    func currentPageSelected(currentPage: Int) {
        print(currentPage)
    }
    var cellType: FeedCellTypeProtocol{
        return MultipleMediaTableViewCellType()
    }
        
    private var cachedMediCollectionCoordinators = [IndexPath : FeedsMediaCollectionCoordinator]()
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        if feed.hasOnlyMedia(){
            return 190
        }else{
            switch feed.getMediaCountState() {
                
            case .None:
                return 0
            case .OneMediaItemPresent(_):
                return 0
            case .TwoMediaItemPresent:
                return 190
            case .MoreThanTwoMediItemPresent:
                return 190
            }
        }
        
    }
    
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? MultipleMediaTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
//                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
               // cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
            let feedTitle = feed.getStrengthData()
//            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as? String ?? "#FFFFFF", alpha: 1.0)
            let backGroundColor = feedTitle["badgeBackgroundColor"] as? String ?? ""
            let backGroundColorLite = feedTitle["background_color_lite"] as? String ?? ""
            if let bgColor = UIColor(hex: backGroundColorLite) {
                cell.containerView?.backgroundColor = bgColor
            }else{
                cell.containerView?.backgroundColor = Rgbconverter.HexToColor(backGroundColor)
            }

            cell.containerView?.clipsToBounds = true
            cell.containerView?.layer.cornerRadius = 8
            cell.containerView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.mediaCollectionView?.decelerationRate = .fast
            (cell.mediaCollectionView?.collectionViewLayout as! MultipleImageFlowLayout).pageCollectionLayoutDelegate = self
            cell.mediaCollectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            getMediaCoordinator(inputModel).loadCollectionView(targetCollectionView: cell.mediaCollectionView)
        }
    }
    
    private func getMediaCoordinator(_ inputModel: FeedCellLoadDataModel) -> FeedsMediaCollectionCoordinator{
        if let mediaCoordinator = cachedMediCollectionCoordinators[inputModel.targetIndexpath]{
            return mediaCoordinator
        }else{
            let coordinator = FeedsMediaCollectionCoordinator(
                InitFeedsMediaCollectionCoordinatorModel(
                    feedsDatasource: inputModel.datasource,
                    feedItemIndex: inputModel.targetIndexpath.section,
                    mediaFetcher: inputModel.mediaFetcher,
                    delegate: inputModel.delegate
                )
            )
            cachedMediCollectionCoordinators[inputModel.targetIndexpath] = coordinator
            return coordinator
        }
    }
    
}

