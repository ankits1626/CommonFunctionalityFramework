//
//  BOUSDetailFeedOutstandingTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class BOUSDetailFeedOutstandingTableViewCell: UITableViewCell {

    @IBOutlet weak var imageContainer : UIView?
    @IBOutlet weak var nominationImageView : UIImageView?
    @IBOutlet weak var badgeImageView : UIImageView?
    @IBOutlet weak var nominationConatiner : UIView?
    @IBOutlet weak var messageContainer : UIView?
    @IBOutlet weak var awardLabel : UILabel?
    @IBOutlet weak var strengthLabel : UILabel?
    @IBOutlet weak var nominationMessage : ActiveLabel?
    @IBOutlet weak var strengthHeightConstraints : NSLayoutConstraint?
    @IBOutlet weak var categoryImageView : UIImageView?
    @IBOutlet weak var categoryName : UILabel?
    
    @IBOutlet weak var teamView : UIView?
    @IBOutlet weak var teamViewHeightConstraints : NSLayoutConstraint?
    
    @IBOutlet weak var badgeName : UILabel?
    @IBOutlet weak var badgePoints : UILabel?
    @IBOutlet weak var strengthIconButton : UIButton?
    
    @IBOutlet weak var strengthIcon : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nominationMessage?.hashtagColor = .black
        imageContainer?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
        messageContainer?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
        nominationConatiner?.clipsToBounds = true
        nominationConatiner?.layer.cornerRadius = 8
        nominationConatiner?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
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
