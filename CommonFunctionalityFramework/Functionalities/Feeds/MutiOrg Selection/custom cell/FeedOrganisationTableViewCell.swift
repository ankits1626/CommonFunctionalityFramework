//
//  FeedOrganisationTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents
class FeedOrganisationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var departmentLbl: UILabel?
    @IBOutlet weak var rowContainer: UIView?
    @IBOutlet weak var itemListener : BlockButton?
    @IBOutlet weak var rowTypeViewContainer : UIView?
    @IBOutlet weak var rowTypeStatusLabel : UILabel?
    @IBOutlet weak var departmentCounts : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rowContainer?.curvedUIBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255), borderWidth: 1.0, cornerRadius: 8.0)        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
