//
//  BOUSThreeImageDetailTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 28/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSThreeImageDetailTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var feedImageView1 : UIImageView?
    @IBOutlet weak var feedImageView2 : UIImageView?
    @IBOutlet weak var remainingImgCount: UILabel!
    @IBOutlet weak var feedImageView3 : UIImageView?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var moreThan3Images: UIImageView!
    @IBOutlet weak var imageTapButton : BlockButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class BOUSThreeImageDetailTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "BOUSThreeImageDetailTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSThreeImageDetailTableViewCell", bundle: Bundle(for: BOUSThreeImageDetailTableViewCell.self))
    }
}

