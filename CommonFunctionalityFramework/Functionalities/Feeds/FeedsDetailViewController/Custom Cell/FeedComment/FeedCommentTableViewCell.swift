//
//  FeedCommentTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 11/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedCommentTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class FeedCommentTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "FeedCommentTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedCommentTableViewCell", bundle: Bundle(for: FeedTopTableViewCell.self))
    }
}
