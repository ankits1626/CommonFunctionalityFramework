//
//  BOUSFeedGrayDividerTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSFeedGrayDivider: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class BOUSFeedGrayDividerCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "BOUSFeedGrayDivider"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSFeedGrayDivider", bundle: Bundle(for: CommonFeedsTopTableViewCell.self))
    }
}
