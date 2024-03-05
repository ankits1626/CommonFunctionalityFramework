//
//  ImageViewSectionViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 29/06/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class ImageViewSectionCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class ImageViewTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "ImageViewSectionCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "ImageViewSectionCell", bundle: Bundle(for: ImageViewSectionCell.self))
    }
}
