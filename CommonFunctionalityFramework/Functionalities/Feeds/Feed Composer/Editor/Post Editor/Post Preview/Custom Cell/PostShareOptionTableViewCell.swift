//
//  PostShareOptionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 03/11/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class PostShareOptionTableViewCell: UITableViewCell {
    @IBOutlet weak var selectedOrgDepartmentLbl : UILabel?
    @IBOutlet weak var bubble : UIView?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubble?.curvedCornerControl(0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


class PostShareOptionTableCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "PostShareOptionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(
            nibName: "PostShareOptionTableViewCell",
            bundle: Bundle(for: PostShareOptionTableViewCell.self)
        )
    }
}
