//
//  SelectPostTypeTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class SelectPostTypeTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView : UIView?
    @IBOutlet weak var posttoDepartment : UISwitch?
    @IBOutlet weak var departmentLabel : UILabel?
    @IBOutlet weak var seperator : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        posttoDepartment?.onTintColor = UIColor.getControlColor()
        posttoDepartment?.tintColor =  UIColor.getControlColor()
        departmentLabel?.text = "Post to my department only".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class SelectPostTypeTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "SelectPostTypeTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "SelectPostTypeTableViewCell", bundle: Bundle(for: SelectPostTypeTableViewCell.self))
    }
}
