//
//  FeedEditorTitleTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedEditorTitleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleText : KMPlaceholderTextView?
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

class FeedEditorTitleTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "FeedEditorTitleTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedEditorTitleTableViewCell", bundle: Bundle(for: FeedTopTableViewCell.self))
    }
}
