//
//  PostPreviewHeaderCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 03/11/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit


struct GetPostPreviewHeaderInput{
    var section: PostPreviewSection
    var table : UITableView?
    var shareOption : SharePostOption
    weak var router : PostEditorRouter?
}

class PostPreviewHeaderCoordinator{
    
    func getHeader(input: GetPostPreviewHeaderInput) -> UIView? {
        switch input.section{
            
        case .PostInfo:
            return nil
        case .ShareWithInfoSection:
            let header = input.table?.dequeueReusableHeaderFooterView(withIdentifier: "FeedDetailHeader") as? FeedDetailHeader
            header?.headerContainer?.addBorders(
                edges: [.left, .right],
                color: .feedCellBorderColor
            )
            header?.headerTitleLabel?.font = UIFont.Highlighter2
            switch input.shareOption{
                
            case .MyOrg:
                fallthrough
            case .MyDepartment:
                header?.headerTitleLabel?.text = "Post to".localized
                header?.headerActionButton?.isHidden = true
            case .MultiOrg:
                header?.headerActionButton?.isHidden = false
                header?.headerTitleLabel?.text = "Selected Organisation".localized
            }
            
            header?.headerSecondaryTitleLabel?.text = nil
            header?.headerActionButton?.setTitle(" ", for: .normal)
            header?.headerActionButton?.tintColor = .black
            header?.headerActionButton?.setImage(
                UIImage(
                    named: "cff_edit",
                    in: Bundle(for: PostEditorViewController.self),
                    compatibleWith: nil
                ),
                for: .normal
            )
            header?.headerActionButton?.handleControlEvent(
                event: .touchUpInside,
                buttonActionBlock: {
                    input.router?.routeToMultiOrgPickerFromPreview()
                })
            
            return header
        }
    }
}
