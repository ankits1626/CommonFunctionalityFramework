//
//  PostEditorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PostEditorViewController: BaseEditorViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
    }
    
    override func setupContainerTopbar() {
        super.setupContainerTopbar()
        containerTopBarModel?.title?.text = "CREATE POST"
    }
}
