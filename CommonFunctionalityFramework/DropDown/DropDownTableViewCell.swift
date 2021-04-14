//
//  DropDownTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 14/04/21.
//  Copyright © 2021 Rewardz. All rights reserved.
//

import UIKit

class DropDownTableViewCell: UITableViewCell {

    @IBOutlet weak var frequncyNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

