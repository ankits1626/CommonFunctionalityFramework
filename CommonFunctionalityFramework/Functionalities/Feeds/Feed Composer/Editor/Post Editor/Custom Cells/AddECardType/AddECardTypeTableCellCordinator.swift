//
//  AddECardTypeTableCellCordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 13/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Loaf

class AddECardTypeTableCellCordinator: NSObject, PostEditorCellCoordinatorProtocol {
    var cellType: FeedCellTypeProtocol = AddECardTableViewCellType()
    weak var themeManager : CFFThemeManagerProtocol?
    var ecardHeight = 144.0
    
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        let cell = inputModel.targetTableView.dequeueReusableCell(
        withIdentifier: cellType.cellIdentifier,
        for: inputModel.targetIndexpath) as! AddECardTableViewCell
        let post = inputModel.datasource.getTargetPost()
        if let eCardImage = post?.selectedEcardMediaItems?.image {
            inputModel.mediaFetcher.fetchImageAndLoad(cell.eCardImageView, imageWithCompleteURL: eCardImage)
            ecardHeight = imageDimenssions(url: eCardImage)
        }
        return cell
    }
    
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        themeManager = inputModel.themeManager
        if let cell = inputModel.targetCell as? AddECardTableViewCell{
            cell.removeButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
                print("<<<<<<<< delete attached mediapo ")
                inputModel.delegate?.removeAttachedECard()
                inputModel.targetTableView?.reloadData()
            })
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        return ecardHeight
    }
    
    func imageDimenssions(url: String) -> CGFloat{
        if let imageSource = CGImageSourceCreateWithURL(URL(string: url)! as CFURL, nil) {
            if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary? {
//                let pixelWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat ?? 0.0
                let pixelHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat ?? 0.0
                return pixelHeight
            }
        }
        return 0.0
    }
    
    weak var delegate : PostEditorCellFactoryDelegate?
    
}

