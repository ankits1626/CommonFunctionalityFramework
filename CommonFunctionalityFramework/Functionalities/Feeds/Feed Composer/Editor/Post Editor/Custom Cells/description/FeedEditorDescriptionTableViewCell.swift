//
//  FeedEditorDescriptionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorDescriptionTableViewCell: UITableViewCell,FeedsCustomCellProtcol {
    @IBOutlet weak var descriptionText : KMPlaceholderTextView?
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

class FeedEditorDescriptionTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "FeedEditorDescriptionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedEditorDescriptionTableViewCell", bundle: Bundle(for: FeedTopTableViewCell.self))
    }
}
