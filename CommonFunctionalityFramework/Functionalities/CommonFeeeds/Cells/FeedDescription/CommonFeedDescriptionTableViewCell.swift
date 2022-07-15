//
//  CommonFeedDescriptionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 05/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class CommonFeedDescriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var feedText : UILabel?
    @IBOutlet weak var readMorebutton : UIButton?
    @IBOutlet weak var appreciationSubjectTxt: UILabel!
    @IBOutlet weak var appreciationSubject : UILabel?
    @IBOutlet weak var containerView : UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


class CommonFeedDescriptionTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "CommonFeedDescriptionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonFeedDescriptionTableViewCell", bundle: Bundle(for: CommonFeedDescriptionTableViewCell.self))
    }
}
