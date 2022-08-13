//
//  AddECardTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 13/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class AddECardTableViewCell: UITableViewCell {

    @IBOutlet weak var eCardImageView : UIImageView?
    @IBOutlet public weak var removeButton : BlockButton?
    @IBOutlet public weak var removeBtnContainer : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeBtnContainer?.layer.cornerRadius = (removeBtnContainer?.frame.size.width)!/2
        removeBtnContainer?.clipsToBounds = true
        removeBtnContainer?.layer.borderColor = UIColor.white.cgColor
        removeBtnContainer?.layer.borderWidth = 2.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class AddECardTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "AddECardTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "AddECardTableViewCell", bundle: Bundle(for: AddECardTableViewCell.self))
    }
}
