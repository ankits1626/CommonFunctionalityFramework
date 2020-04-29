//
//  MultipleMediaTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class MultipleMediaTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var mediaCollectionView : UICollectionView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class MultipleMediaTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "MultipleMediaTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "MultipleMediaTableViewCell", bundle: Bundle(for: MultipleMediaTableViewCell.self))
    }
}
