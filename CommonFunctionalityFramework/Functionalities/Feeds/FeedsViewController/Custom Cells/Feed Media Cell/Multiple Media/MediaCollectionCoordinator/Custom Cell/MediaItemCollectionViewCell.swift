//
//  MediaItemCollectionViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 06/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class MediaItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mediaCoverImageView : UIImageView?
    @IBOutlet weak var removeButton : BlockButton?
    @IBOutlet weak var playButton : BlockButton?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
