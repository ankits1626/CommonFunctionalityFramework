//
//  SelectPostMediaTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class SelectPostMediaTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    var containerView: UIView?
    @IBOutlet weak var ecardButton : UIButton?
    @IBOutlet weak var gifButton : UIButton?
    @IBOutlet weak var imageButton : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class SelectPostMediaTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "SelectPostMediaTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "SelectPostMediaTableViewCell", bundle: Bundle(for: SelectPostMediaTableViewCell.self))
    }
}
