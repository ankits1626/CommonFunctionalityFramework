//
//  SingleVideoTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class SingleVideoTableViewCell: UITableViewCell {
    @IBOutlet weak var feedVideoImageView : UIImageView?
    @IBOutlet weak var feedVideoPlayButton : UIButton?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var removeButton : BlockButton?
    @IBOutlet weak var videoTapButton : BlockButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class SingleVideoTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "SingleVideoTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "SingleVideoTableViewCell", bundle: Bundle(for: SingleVideoTableViewCell.self))
    }
}

