//
//  PollSubmitButtonCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollSubmitButtonCell: UITableViewCell {
    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var submitButton : BlockButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


class PollSubmitButtonCellType : FeedCellTypeProtocol{
    var cellIdentifier: String{
        return "PollSubmitButtonCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "PollSubmitButtonCell", bundle: Bundle(for: PollSubmitButtonCell.self))
    }
}
