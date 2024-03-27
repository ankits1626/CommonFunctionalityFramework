//
//  MultiLineNominationQuestionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 31/01/24.
//  Copyright © 2024 Rewardz. All rights reserved.
//

import UIKit

class MultiLineNominationQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel : UILabel?
    @IBOutlet weak var questionansers : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class MultiLineNominationQuestionTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "MultiLineNominationQuestionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "MultiLineNominationQuestionTableViewCell", bundle: Bundle(for: MultiLineNominationQuestionTableViewCell.self))
    }
}
