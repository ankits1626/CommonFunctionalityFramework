//
//  PostPollTopTableViewCellTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 14/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class PostPollTopTableViewCellTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var profileImage : UIImageView?
    @IBOutlet weak var userName : UILabel?
    @IBOutlet weak var departmentName : UILabel?
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var headerGrayViewHeight: NSLayoutConstraint!
    @IBOutlet weak var editFeedButton : BlockButton?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var pinPostButton : BlockButton?
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinPostWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class PostPollTopTableViewCellTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "PostPollTopTableViewCellTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PostPollTopTableViewCellTableViewCell", bundle: Bundle(for: PostPollTopTableViewCellTableViewCell.self))
    }
}
