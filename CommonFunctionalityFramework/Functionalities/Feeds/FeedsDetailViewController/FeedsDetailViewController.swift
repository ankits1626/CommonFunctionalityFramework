//
//  FeedsDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class FeedsDetailViewController: UIViewController {
    @IBOutlet weak var commentBarView : ASChatBarview?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension FeedsDetailViewController : ASChatBarViewDelegate{
    func finishedPresentingOverKeyboard() {
        
    }
    
    func addAttachmentButtonPressed() {
        
    }
    
    func removeAttachment() {
        
    }
    
    func rightButtonPressed(_ chatBar: ASChatBarview) {
        
    }
    
    
}
