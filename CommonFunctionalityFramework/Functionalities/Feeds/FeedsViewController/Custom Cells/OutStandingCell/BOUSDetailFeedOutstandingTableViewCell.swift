//
//  BOUSDetailFeedOutstandingTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSDetailFeedOutstandingTableViewCell: UITableViewCell {

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

class FeedDetailOutstandingTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "BOUSDetailFeedOutstandingTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSDetailFeedOutstandingTableViewCell", bundle: Bundle(for: BOUSDetailFeedOutstandingTableViewCell.self))
    }
}
