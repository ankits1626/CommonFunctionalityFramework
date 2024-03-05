//
//  FeedDetailHeader.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 16/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class FeedDetailHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var headerContainer : UIView?
    @IBOutlet weak var headerTitleLabel : UILabel?
    @IBOutlet weak var headerSecondaryTitleLabel : UILabel?
    @IBOutlet weak var headerActionButton : BlockButton?
    @IBOutlet weak var titleLeftConstraint : NSLayoutConstraint?
    @IBOutlet weak var actionButtonRightConstraint : NSLayoutConstraint?
}
