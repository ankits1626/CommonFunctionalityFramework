//
//  BOUSReactionsScrollListTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 22/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSReactionsScrollListTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class BOUSReactionScrollListTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "BOUSReactionsScrollListTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSReactionsScrollListTableViewCell", bundle: Bundle(for: BOUSReactionsScrollListTableViewCell.self))
    }
}

