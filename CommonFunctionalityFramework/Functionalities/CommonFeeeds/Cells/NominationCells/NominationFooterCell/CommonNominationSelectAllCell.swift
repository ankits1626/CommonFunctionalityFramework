//
//  CommonNominationSelectAllCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 03/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonNominationSelectAllCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class CommonNominationSelectAllCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "CommonNominationSelectAllCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonNominationSelectAllCell", bundle: Bundle(for: CommonNominationSelectAllCell.self))
    }
}
