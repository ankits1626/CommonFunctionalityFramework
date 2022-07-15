//
//  CommonOutastandingImageTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/06/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonOutastandingImageTableViewCell: UITableViewCell {

    @IBOutlet weak var awardImg: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var awardTitle: UILabel!
    @IBOutlet weak var awardSubTitle: UILabel!
    @IBOutlet weak var awardDescription: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class CommonOutastandingImageTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "CommonOutastandingImageTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonOutastandingImageTableViewCell", bundle: Bundle(for: CommonOutastandingImageTableViewCell.self))
    }
}
