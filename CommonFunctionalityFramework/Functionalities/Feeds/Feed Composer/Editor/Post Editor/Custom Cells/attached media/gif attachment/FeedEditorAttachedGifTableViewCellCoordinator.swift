//
//  FeedEditorAttachedGifTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import FLAnimatedImage

class FeedEditorAttachedGifTableViewCellCoordinator :  PostEditorCellCoordinatorProtocol{
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        //return  273
        return UITableView.automaticDimension
    }
    
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        let cell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath) as! FeedGifTableViewCell
        let post = inputModel.datasource.getTargetPost()
        if let rawGif = post?.attachedGif?.getGifSourceUrl() {
            if let data = CFFGifCacheManager.sharedInstance.gifCache.object(forKey: rawGif as NSString) as Data?{
                print("<<<<<<<<<< picked from cache")
                cell.feedGifImage?.animatedImage = FLAnimatedImage(animatedGIFData: data)
            }else{
                cell.feedGifImage?.animatedImage = nil
                cell.imageLoader?.startAnimating()
                let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string:rawGif)!)) { (data, _, _) in
                  DispatchQueue.main.async {
                    cell.imageLoader?.stopAnimating()
                    if let unwrappeData = data as? NSData{
                        CFFGifCacheManager.sharedInstance.gifCache.setObject(unwrappeData, forKey: rawGif as NSString)
                        inputModel.targetTableView.reloadRows(at: [inputModel.targetIndexpath], with: .none)
                    }
                  }
                }
                task.resume()
            }
        }
        
        return cell
    }
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedGifTableViewCell{
            cell.selectionStyle = .none
            cell.containerView?.addBorders(edges: [.bottom, .left, .right], color: .feedCellBorderColor)
            cell.containerView?.curvedCornerControl()
            cell.removeButton?.isHidden = false
            cell.removeButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
                print("<<<<<<<< delete attached mediapo ")
                inputModel.delegate?.removeAttachedGif()
                //post?.attachedGif = nil
                inputModel.targetTableView?.reloadData()
            })
        }
    }
    
    var cellType: FeedCellTypeProtocol{
        return FeedGifTableViewCellType()
    }
}

class FeedAttachedGifTableViewCellCoordinator : FeedCellCoordinatorProtocol{
    var cellType: FeedCellTypeProtocol{
        return FeedGifTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        let cell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath) as! FeedGifTableViewCell
        let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
        let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(
            feedId: feed.feedIdentifier,
            description: feed.getFeedDescription()
        )
        if let rawGif = model?.attachedGif {
            if let data = CFFGifCacheManager.sharedInstance.gifCache.object(forKey: rawGif as NSString) as Data?{
                print("<<<<<<<<<< picked from cache")
                cell.feedGifImage?.animatedImage = FLAnimatedImage(animatedGIFData: data)
            }else{
                cell.feedGifImage?.animatedImage = nil
                cell.imageLoader?.startAnimating()
                let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string:rawGif)!)) { (data, _, _) in
                  DispatchQueue.main.async {
                    cell.imageLoader?.stopAnimating()
                    if let unwrappeData = data as NSData?{
                        CFFGifCacheManager.sharedInstance.gifCache.setObject(unwrappeData, forKey: rawGif as NSString)
                        inputModel.targetTableView.reloadRows(at: [inputModel.targetIndexpath], with: .none)
                        //self.gifCollection?.reloadItems(at: [indexPath])
                    }
                  }
                }
                task.resume()
            }
        }
        return cell
    }
    
    func loadDataCell(_ inputModel: FeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? FeedGifTableViewCell{
            cell.removeButton?.isHidden = true
        }
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
