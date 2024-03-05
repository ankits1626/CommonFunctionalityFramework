//
//  FeedTitleTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class FeedTitleTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    
    @IBOutlet weak var feedText : ActiveLabel?
    @IBOutlet weak var readMorebutton : UIButton?
    @IBOutlet weak var appreciationSubject : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var pointBtn: UIButton!
    @IBOutlet weak var pointBtnHeightConstraints : NSLayoutConstraint?
    @IBOutlet weak var feedThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class FeedTitleTableViewCellType : FeedCellTypeProtocol{
    var cellIdentifier: String{
        return "FeedTitleTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedTitleTableViewCell", bundle: Bundle(for: FeedTitleTableViewCell.self))
    }
}
