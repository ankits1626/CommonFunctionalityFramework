//
//  FeedGifTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import FLAnimatedImage

class FeedGifTableViewCell: UITableViewCell {
    @IBOutlet weak var feedGifImage: FLAnimatedImageView?
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

class FeedGifTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "FeedGifTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "FeedGifTableViewCell", bundle: Bundle(for: FeedEditorPollOptionTableViewCell.self))
    }
}
