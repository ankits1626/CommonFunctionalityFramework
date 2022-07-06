//
//  CommonNominationCountCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 03/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit


class CommonNominationCountCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

class CommonNominationCountCellType : CommonFeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "CommonNominationCountCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonNominationCountCell", bundle: Bundle(for: CommonNominationCountCell.self))
    }
}
