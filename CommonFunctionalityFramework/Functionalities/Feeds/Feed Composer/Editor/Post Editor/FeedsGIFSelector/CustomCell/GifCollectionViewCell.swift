//
//  GifCollectionViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 09/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import FLAnimatedImage

class GifCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var gifImage : FLAnimatedImageView?
    @IBOutlet weak var identifierLabel : UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
