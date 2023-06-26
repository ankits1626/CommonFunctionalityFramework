//
//  SelectPostMediaTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class SelectPostMediaTableViewCell: UITableViewCell, FeedsCustomCellProtcol {
    var containerView: UIView?
    @IBOutlet weak var ecardButton : UIButton?
    @IBOutlet weak var gifButton : UIButton?
    @IBOutlet weak var imageButton : UIButton?
    
    @IBOutlet weak var ecardLabel : UILabel?
    @IBOutlet weak var gifLabel : UILabel?
    @IBOutlet weak var imageLabel : UILabel?
    
    @IBOutlet weak var ecardButtonView : UIView?
    @IBOutlet weak var gifButtonView : UIView?
    @IBOutlet weak var imageButtonView : UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ecardLabel?.text = "eCard".localized
        gifLabel?.text = "GIF".localized
        imageLabel?.text = "Image".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class SelectPostMediaTableViewCellType : FeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "SelectPostMediaTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "SelectPostMediaTableViewCell", bundle: Bundle(for: SelectPostMediaTableViewCell.self))
    }
}
