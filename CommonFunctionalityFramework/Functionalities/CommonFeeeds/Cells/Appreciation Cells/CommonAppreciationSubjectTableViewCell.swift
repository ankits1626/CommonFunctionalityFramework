//
//  CommonAppreciationSubjectTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class CommonAppreciationSubjectTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedText : ActiveLabel?
    @IBOutlet weak var readMorebutton : UIButton?
    @IBOutlet weak var appreciationSubject : UILabel?
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var feedThumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedText?.hashtagColor = .black
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class CommonAppreciationSubjectTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "CommonAppreciationSubjectTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonAppreciationSubjectTableViewCell", bundle: Bundle(for: CommonAppreciationSubjectTableViewCell.self))
    }
}
