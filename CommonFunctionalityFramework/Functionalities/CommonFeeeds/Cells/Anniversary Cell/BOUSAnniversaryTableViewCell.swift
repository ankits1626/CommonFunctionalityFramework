//
//  BOUSAnniversaryTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 03/02/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class BOUSAnniversaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userNameTitle: UILabel!
    @IBOutlet weak var wishType: UIImageView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var imageHolder: UIView!
    @IBOutlet weak var departmentTitle: UILabel!
    @IBOutlet weak var wishTitle: UILabel!
    @IBOutlet weak var bgTransparentImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class BOUSAnniversaryTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "BOUSAnniversaryTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "BOUSAnniversaryTableViewCell", bundle: Bundle(for: BOUSAnniversaryTableViewCell.self))
    }
}
