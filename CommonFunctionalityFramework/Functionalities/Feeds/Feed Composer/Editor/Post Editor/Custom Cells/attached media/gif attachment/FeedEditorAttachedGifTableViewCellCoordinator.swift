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
        if let rawGif = post?.attachedGiflyGif {
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
            cell.imageTapButton?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
            cell.removeButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
                print("<<<<<<<< delete attached mediapo ")
                inputModel.delegate?.removeAttachedGif()
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
        if let rawGif = feed.getGiphy(), !rawGif.isEmpty {
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
                        
                        if let visibleIndexpaths = inputModel.targetTableView.indexPathsForVisibleRows,
                            visibleIndexpaths.contains(inputModel.targetIndexpath){
                            inputModel.targetTableView.reloadRows(at: [inputModel.targetIndexpath], with: .none)
                        }else{
                            print("<<<<<<<<<<<<< let it be probably table not visible >>>>>>>>>>")
                        }
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
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            cell.removeButton?.isHidden = true
            cell.imageTapButton?.backgroundColor = .clear
            if feed.isPinToPost() && !inputModel.isFeedDetailPage {
                cell.containerView?.addBorders(edges: [.left, .right], color: inputModel.themeManager != nil ? inputModel.themeManager!.getControlActiveColor()  : .pinToPostCellBorderColor)
            }else{
                cell.containerView?.addBorders(edges: [.left, .right], color: .feedCellBorderColor)
            }
        }
    }
    
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
