//
//  BOUSThreeImagesTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 28/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSThreeImagesTableViewCell: UITableViewCell {
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

class BOUSThreeImagesTableViewCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "BOUSThreeImagesTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSThreeImagesTableViewCell", bundle: Bundle(for: BOUSThreeImagesTableViewCell.self))
    }
}
