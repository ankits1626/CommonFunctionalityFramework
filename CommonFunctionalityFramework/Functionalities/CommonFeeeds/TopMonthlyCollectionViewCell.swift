//
//  TopMonthlyCollectionViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/04/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class TopMonthlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var heroImageView : UIImageView?
    @IBOutlet weak var heroImageViewContainer : UIView?
    @IBOutlet weak var appreciationCountLabel : UILabel?
    @IBOutlet weak var appreciationCountView : UIView?
    @IBOutlet weak var heroNameLabel : UILabel?
    @IBOutlet weak var cancelFeedButton : UIButton?
    @IBOutlet weak var cancelParentFeedButton : UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
