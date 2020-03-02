//
//  BaseFeedTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit

class BaseFeedTableViewCell: UITableViewCell {
  
  @IBOutlet weak var profileImage : UIImageView?
  @IBOutlet weak var userName : UILabel?
  @IBOutlet weak var departmentName : UILabel?
  @IBOutlet weak var editFeedButton : UIButton?
  @IBOutlet weak var feedTitle : UILabel?
  @IBOutlet weak var feedText : UILabel?
  @IBOutlet weak var clapsButton : UIButton?
  @IBOutlet weak var clapsCountLabel : UILabel?
  @IBOutlet weak var commentsButton : UIButton?
  @IBOutlet weak var commentsCountLabel : UILabel?
  

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
