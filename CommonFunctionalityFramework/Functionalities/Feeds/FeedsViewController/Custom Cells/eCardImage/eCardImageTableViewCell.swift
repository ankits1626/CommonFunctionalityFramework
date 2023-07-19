//
//  eCardImageTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 12/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class eCardImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedImageView : UIImageView?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var removeButton : BlockButton?
    @IBOutlet weak var imageTapButton : BlockButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class eCardImageTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "eCardImageTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "eCardImageTableViewCell", bundle: Bundle(for: eCardImageTableViewCell.self))
    }
}
