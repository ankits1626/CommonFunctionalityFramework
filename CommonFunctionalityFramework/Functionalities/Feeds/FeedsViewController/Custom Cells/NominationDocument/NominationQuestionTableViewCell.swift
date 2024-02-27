//
//  NominationQuestionTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 31/01/24.
//  Copyright © 2024 Rewardz. All rights reserved.
//

import UIKit

class NominationQuestionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var attachmentContainerView : UIView?
    @IBOutlet weak var attachmentName : UILabel?
    @IBOutlet weak var attachmentImage : UIImageView?
    @IBOutlet weak var noDatalabel : UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

class NominationAttachmentTableViewCellType : FeedCellTypeProtocol{
    
    var cellIdentifier: String{
        return "NominationQuestionTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "NominationQuestionTableViewCell", bundle: Bundle(for: NominationQuestionTableViewCell.self))
    }
}
