//
//  TopGettersFilterHeader.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation
import RewardzCommonComponents
import UIKit

class TopGettersFilterHeader: UICollectionReusableView {
    @IBOutlet weak var title : UILabel?
    @IBOutlet weak var titleView : UIView?
    @IBOutlet weak var actionButtonView : UIView?
    @IBOutlet weak var actionButton : BlockButton?
    @IBOutlet weak var actionButtonWidth : NSLayoutConstraint?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
