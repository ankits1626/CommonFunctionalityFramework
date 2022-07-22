//
//  BOUSMultipleImageTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSMultipleImageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


class BOUSMultipleImageTableViewCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "BOUSMultipleImageTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSMultipleImageTableViewCell", bundle: Bundle(for: BOUSMultipleImageTableViewCell.self))
    }
}
