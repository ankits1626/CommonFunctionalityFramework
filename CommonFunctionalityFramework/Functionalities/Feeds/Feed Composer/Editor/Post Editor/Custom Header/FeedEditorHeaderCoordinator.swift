//
//  FeedEditorHeaderCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 15/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct GetPostEditorDetailtableHeaderInput{
    var section: PostEditorSection
    var table : UITableView?
}

class FeedEditorHeaderCoordinator {
    weak var postEditorDataSource : PostEditorCellFactoryDatasource?
    init(dataSource: PostEditorCellFactoryDatasource?) {
        self.postEditorDataSource = dataSource
    }
    func getHeader(input: GetPostEditorDetailtableHeaderInput) -> UIView? {
        switch input.section {
            
        case .Media:
            let header = input.table?.dequeueReusableHeaderFooterView(withIdentifier: "FeedDetailHeader") as? FeedDetailHeader
            header?.headerContainer?.addBorders(
                edges: [.left, .right],
                color: .feedCellBorderColor
            )
            header?.headerTitleLabel?.font = UIFont.Highlighter1
            header?.headerTitleLabel?.textColor = .stepperInactiveColor
            header?.headerTitleLabel?.text = "PHOTOS"
            header?.headerSecondaryTitleLabel?.isHidden = true
            //configureHeader(ConfigureHeaderInput(view: header, section: input.section))
            return header
        case .Title:
            fallthrough
        case .Description:
            fallthrough
            
        case .PollOptions:
            fallthrough
        case .PollActiveForDays:
            return nil
        }
    }
    
    func configureHeader(_ input : ConfigureHeaderInput){
    }
    
    
    
    func getHeight(section: PostEditorSection) -> CGFloat {
        switch section {
        case .Media:
            return postEditorDataSource?.getTargetPost()?.postType == FeedType.Post ?  20 : 0
        case .Title:
            fallthrough
        case .Description:
            fallthrough
            
        case .PollOptions:
            fallthrough
        case .PollActiveForDays:
            return 0
        }
    }
}
