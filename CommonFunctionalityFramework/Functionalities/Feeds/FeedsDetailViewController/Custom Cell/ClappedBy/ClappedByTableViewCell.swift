//
//  ClappedByTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 11/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class ClappedByTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ClappedByTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "ClappedByTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "ClappedByTableViewCell", bundle: Bundle(for: FeedTopTableViewCell.self))
    }
}
