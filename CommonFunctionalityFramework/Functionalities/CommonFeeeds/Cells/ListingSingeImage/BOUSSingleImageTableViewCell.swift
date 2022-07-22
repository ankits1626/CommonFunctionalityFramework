//
//  BOUSSingleImageTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSSingleImageTableViewCell: UITableViewCell {

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
    }
    
}

class BOUSSingleImageTableViewCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "BOUSSingleImageTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSSingleImageTableViewCell", bundle: Bundle(for: BOUSSingleImageTableViewCell.self))
    }
}
