//
//  CommonOutastandingImageTableViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/06/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import ActiveLabel

class CommonOutastandingImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageContainer : UIView?
    @IBOutlet weak var nominationImageView : UIImageView?
    @IBOutlet weak var badgeImageView : UIImageView?
    @IBOutlet weak var nominationConatiner : UIView?
    @IBOutlet weak var messageContainer : UIView?
    @IBOutlet weak var awardLabel : UILabel?
    @IBOutlet weak var strengthLabel : UILabel?
    @IBOutlet weak var nominationMessage : ActiveLabel?
    @IBOutlet weak var strengthHeightConstraints : NSLayoutConstraint?
    @IBOutlet weak var categoryImageView : UIImageView?
    @IBOutlet weak var categoryName : UILabel?
    
    @IBOutlet weak var badgeName : UILabel?
    @IBOutlet weak var badgePoints : UILabel?
    @IBOutlet weak var strengthIconButton : UIButton?
    
    @IBOutlet weak var strengthIcon : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        nominationMessage?.hashtagColor = .black
        imageContainer?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
        messageContainer?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
        nominationConatiner?.clipsToBounds = true
        nominationConatiner?.layer.cornerRadius = 8
        nominationConatiner?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

class CommonOutastandingImageTableViewCellType : CommonFeedCellTypeProtocol{
   
    var cellIdentifier: String{
        return "CommonOutastandingImageTableViewCell"
    }
    
    var cellNib: UINib?{
        return UINib(nibName: "CommonOutastandingImageTableViewCell", bundle: Bundle(for: CommonOutastandingImageTableViewCell.self))
    }
}


public extension UIView {
    func curvedUIBorderedControl(borderColor : UIColor = UIColor.getGeneralBorderColor(),borderWidth : CGFloat  = 1.0, cornerRadius : CGFloat = 8.0) {
        self.layer.cornerRadius = cornerRadius
        borderedUIControl(borderColor: borderColor, borderWidth: borderWidth)
    }
    
    func borderedUIControl(borderColor : UIColor = UIColor.getGeneralBorderColor(), borderWidth : CGFloat  = 1.0 ) {
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    func addShadowToView() {
        self.layer.shadowColor = Rgbconverter.HexToColor("#202970", alpha: 0.04).cgColor
      self.layer.shadowOffset = CGSize(width: 1, height: 1)
      self.layer.shadowOpacity = 1
    }
}
