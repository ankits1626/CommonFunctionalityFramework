//
//  CommonLikesSectionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonLikesSectionTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class CommonLikesSectionTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "CommonLikesSectionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonLikesSectionTableViewCell", bundle: Bundle(for: CommonLikesSectionTableViewCell.self))
    }
}
