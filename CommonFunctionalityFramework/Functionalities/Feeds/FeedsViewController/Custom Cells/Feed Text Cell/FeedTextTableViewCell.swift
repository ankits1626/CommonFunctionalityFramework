//
//  FeedTestTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedTextTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var feedText : UILabel?
    @IBOutlet weak var readMorebutton : UIButton?
    @IBOutlet weak var containerView : UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class FeedTextTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "FeedTextTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedTextTableViewCell", bundle: Bundle(for: FeedTextTableViewCell.self))
    }
}
