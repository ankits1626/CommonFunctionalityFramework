//
//  AnniversaryDetailTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 08/02/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class AnniversaryDetailTableViewCell: UITableViewCell {
    
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

class AnniversaryDetailTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "AnniversaryDetailTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "AnniversaryDetailTableViewCell", bundle: Bundle(for: AnniversaryDetailTableViewCell.self))
    }
}
