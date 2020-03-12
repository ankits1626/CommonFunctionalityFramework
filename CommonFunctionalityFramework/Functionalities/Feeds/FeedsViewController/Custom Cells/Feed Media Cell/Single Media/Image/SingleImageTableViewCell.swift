//
//  SingleImageTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleImageTableViewCell: UITableViewCell {
    @IBOutlet weak var feedImageView : UIImageView?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var removeButton : BlockButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

class SingleImageTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "SingleImageTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "SingleImageTableViewCell", bundle: Bundle(for: SingleImageTableViewCell.self))
    }
}
