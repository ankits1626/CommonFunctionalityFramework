//
//  ComentAttachedDocumentCollectionViewCell.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class ComentAttachedDocumentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var documentNameLbl: UILabel?
    @IBOutlet weak var deleteDocument: BlockButton?
    @IBOutlet weak var viewDocument: BlockButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
