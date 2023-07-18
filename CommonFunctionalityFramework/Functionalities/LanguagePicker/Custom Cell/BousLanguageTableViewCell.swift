//
//  BousLanguageTableViewCell.swift
//  SKOR
//
//  Created by Suyesh Kandpal on 14/07/22.
//  Copyright © 2022 Rewradz Private Limited. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class BousLanguageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel : UILabel?
    @IBOutlet weak var checkBox : SKORCheckBOX?
    @IBOutlet weak var languageconatiner : UIView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
