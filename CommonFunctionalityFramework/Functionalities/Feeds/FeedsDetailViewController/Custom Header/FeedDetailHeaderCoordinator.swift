//
//  FeedDetailHeaderCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 16/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit


class FeedDetailHeaderCoordinator {
    let feedDataSource : FeedsDatasource
    init(dataSource: FeedsDatasource) {
        self.feedDataSource = dataSource
    }
    func getHeader(section: FeedDetailSection, table : UITableView) -> UIView? {
        switch section {
        case .FeedInfo:
            return nil
        case .ClapsSection:
            fallthrough
        case .Comments:
            let header = table.dequeueReusableHeaderFooterView(withIdentifier: "FeedDetailHeader") as? FeedDetailHeader
            header?.headerContainer?.addBorders(
                edges: [.left, .right],
                color: UIColor.getGeneralBorderColor()
            )
            header?.headerTitleLabel?.font = UIFont.Highlighter2
            header?.headerSecondaryTitleLabel?.font = UIFont.Caption1
            header?.headerSecondaryTitleLabel?.textColor = .getSubTitleTextColor()
            configureHeader(header, section: section)
            return header
        }
    }
    func configureHeader(_ view : FeedDetailHeader?, section: FeedDetailSection){
        switch section {
        case .FeedInfo:
            print("feed info")
        case .ClapsSection:
            configureClapsHeader(view)
        case .Comments:
            configureCommentsHeader(view)
        }
    }
    
    private func configureCommentsHeader(_ view : FeedDetailHeader?){
        view?.headerTitleLabel?.text = "Comments"
        if let commentsCount = feedDataSource.getComments()?.count{
            view?.headerSecondaryTitleLabel?.text = "\(commentsCount) comment\(commentsCount == 1 ? "" : "s")"
        }else{
            view?.headerSecondaryTitleLabel?.text = nil
        }
    }
    
    private func configureClapsHeader(_ view : FeedDetailHeader?){
        view?.headerTitleLabel?.text = "Claps"
        if let clapsCount = feedDataSource.getClappedByUsers()?.count{
            view?.headerSecondaryTitleLabel?.text = "\(clapsCount) clap\(clapsCount == 1 ? "" : "s")"
        }else{
            view?.headerSecondaryTitleLabel?.text = nil
        }
    }
    
    func getHeight(section: FeedDetailSection) -> CGFloat {
        switch section {
        case .FeedInfo:
            return 0
        case .ClapsSection:
            fallthrough
        case .Comments:
            return 40
        }
    }
}
