//
//  SelectMediaTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Loaf

class SelectMediaTableViewCellCoordinator: NSObject, PostEditorCellCoordinatorProtocol {
    var cellType: FeedCellTypeProtocol = SelectPostMediaTableViewCellType()
    weak var themeManager : CFFThemeManagerProtocol?
    
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel) {
        self.delegate = inputModel.delegate
        themeManager = inputModel.themeManager
        if let cell = inputModel.targetCell as? SelectPostMediaTableViewCell{
            if let shouldDisplayECard = inputModel.datasource.getTargetPost()?.isECardAttached(),
               shouldDisplayECard || inputModel.datasource.getTargetPost()?.remoteAttachedMedia?.count ?? 0 > 0 || inputModel.datasource.getTargetPost()?.selectedMediaItems?.count ?? 0 > 0 {
                cell.gifButtonView?.alpha = 0.3
                cell.gifButtonView?.alpha = 0.3
                cell.gifButton?.isUserInteractionEnabled = false
            }else if let shouldDisplayGif = inputModel.datasource.getTargetPost()?.isGifAttached(),
                     shouldDisplayGif{
                cell.imageButtonView?.alpha = 0.3
                cell.ecardButtonView?.alpha = 0.3
                cell.imageButton?.isUserInteractionEnabled = false
                cell.ecardButton?.isUserInteractionEnabled = false
            }else{
                cell.gifButtonView?.alpha = 1.0
                cell.gifButton?.isUserInteractionEnabled = true
                cell.imageButtonView?.alpha = 1.0
                cell.ecardButtonView?.alpha = 1.0
                cell.imageButton?.isUserInteractionEnabled = true
                cell.ecardButton?.isUserInteractionEnabled = true
            }
            cell.imageButton?.addTarget(self, action: #selector(SelectMediaTableViewCellCoordinator.openImages(_:)), for: UIControl.Event.touchUpInside)
            cell.gifButton?.addTarget(self, action: #selector(SelectMediaTableViewCellCoordinator.opengifs(_:)), for: UIControl.Event.touchUpInside)
            cell.ecardButton?.addTarget(self, action: #selector(SelectMediaTableViewCellCoordinator.openEcards(_:)), for: UIControl.Event.touchUpInside)
            cell.gifButtonView?.isHidden = !(inputModel.mainAppCoordinator?.isGifAttachmentAllowedToPost() ?? false)
            cell.imageButtonView?.isHidden = !(inputModel.mainAppCoordinator?.isMediaAttachmentAllowedToPost() ?? false)
            cell.ecardButtonView?.isHidden = !(inputModel.mainAppCoordinator?.isMediaAttachmentAllowedToPost() ?? false)
        }
    }
    
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat {
        let isGifAailable = (inputModel.mainAppCoordinator?.isGifAttachmentAllowedToPost() ?? false)
        let isMediaAttachmentAailable = (inputModel.mainAppCoordinator?.isMediaAttachmentAllowedToPost() ?? false)
        return (isGifAailable || isMediaAttachmentAailable) ?  104 : 0
    }
    
    @IBAction func openImages(_ sender: Any) {
        delegate?.openPhotoLibrary()
    }
    
    @IBAction func opengifs(_ sender: Any) {
        delegate?.openGif()
    }
    
    @IBAction func openEcards(_ sender: Any) {
        delegate?.openECard()
    }
    
    weak var delegate : PostEditorCellFactoryDelegate?
    
}


