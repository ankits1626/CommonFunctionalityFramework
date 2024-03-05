//
//  FeedDetailHeaderCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 16/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct ConfigureHeaderInput {
    var view : FeedDetailHeader?
    var section: FeedDetailSection
}

struct GetFeedDetailtableHeaderInput{
    var section: FeedDetailSection
    var table : UITableView?
}


class FeedDetailHeaderCoordinator {
    let feedDataSource : FeedsDatasource
    weak var delegate: FeedsDelegate?
    weak var themeManager: CFFThemeManagerProtocol?
    
    init(dataSource: FeedsDatasource, delegate: FeedsDelegate?, themeManager: CFFThemeManagerProtocol?) {
        self.feedDataSource = dataSource
        self.delegate = delegate
        self.themeManager = themeManager
    }
    
    func getHeader(input: GetFeedDetailtableHeaderInput) -> UIView? {
        switch input.section {
        case .FeedInfo:
            return nil
        case .ClapsSection:
            fallthrough
        case .Comments:
            let header = input.table?.dequeueReusableHeaderFooterView(withIdentifier: "FeedDetailHeader") as? FeedDetailHeader
            header?.headerContainer?.addBorders(
                edges: [.left, .right],
                color: .feedCellBorderColor
            )
            header?.headerTitleLabel?.font = UIFont.Highlighter2
            header?.headerSecondaryTitleLabel?.font = UIFont.Caption1
            header?.headerSecondaryTitleLabel?.textColor = .getSubTitleTextColor()
            configureHeader(ConfigureHeaderInput(view: header, section: input.section))
            return header
        }
    }
    func configureHeader(_ input : ConfigureHeaderInput){
        switch input.section {
        case .FeedInfo:
            print("feed info")
        case .ClapsSection:
            configureClapsHeader(input.view)
        case .Comments:
            configureCommentsHeader(input.view)
        }
    }
    
    private func configureCommentsHeader(_ view : FeedDetailHeader?){
        if let commentsCount =  feedDataSource.getCommentProvider()?.getNumberOfComments() {
            if commentsCount > 1 {
                view?.headerTitleLabel?.text = "\(commentsCount) \("Comments".localized)".localized
            }else {
                view?.headerTitleLabel?.text = "\(commentsCount) \("Comment".localized)".localized
            }
        }
        
        view?.headerActionButton?.isHidden = true
        view?.headerSecondaryTitleLabel?.text = nil
    }
    
    private func configureClapsHeader(_ view : FeedDetailHeader?){
        if let reactionCount = feedDataSource.getClappedByUsers() {
            if reactionCount.count > 1 {
                view?.headerTitleLabel?.text = "\(reactionCount.count) \("Reactions".localized)".localized
            }else {
                view?.headerTitleLabel?.text = "\(reactionCount.count) \("Reaction".localized)".localized
            }
            
        }
        view?.headerActionButton?.setTitle("SEE ALL".localized, for: .normal)
        view?.headerActionButton?.setTitleColor(themeManager?.getControlActiveColor() ?? .bottomButtonTextColor, for: .normal)
        view?.headerActionButton?.titleLabel?.font = .Highlighter1
        view?.headerActionButton?.isHidden = true
        view?.headerSecondaryTitleLabel?.text = nil
        view?.headerActionButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {[weak self] in
            self?.delegate?.showPostReactions()
        })
        
    }
    
    func getHeight(section: FeedDetailSection) -> CGFloat {
        switch section {
        case .FeedInfo:
            return 0
        case .ClapsSection:
            if let clappedByUsers = feedDataSource.getClappedByUsers(),
            !clappedByUsers.isEmpty{
                 return 30
            }
            
        case .Comments:
            if let comments = feedDataSource.getCommentProvider()?.getNumberOfComments(),
            comments != 0 {
                return 30
            }
        }
        return 0
    }
}
