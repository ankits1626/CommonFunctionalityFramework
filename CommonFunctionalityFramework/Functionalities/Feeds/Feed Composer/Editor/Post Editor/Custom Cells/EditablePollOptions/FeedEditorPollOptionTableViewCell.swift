//
//  FeedEditorPollOptionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 13/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorPollOptionTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var descriptionText : KMPlaceholderTextView?
    @IBOutlet weak var maxCharacterLabel : UILabel?
    @IBOutlet weak var containerView : UIView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class FeedEditorPollOptionTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "FeedEditorPollOptionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedEditorPollOptionTableViewCell", bundle: Bundle(for: FeedEditorPollOptionTableViewCell.self))
    }
}

