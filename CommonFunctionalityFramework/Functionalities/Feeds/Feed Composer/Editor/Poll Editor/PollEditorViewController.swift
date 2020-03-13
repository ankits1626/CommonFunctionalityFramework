//
//  PollEditorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class PollEditorViewController: UIViewController {
    var containerTopBarModel : EditorContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    @IBOutlet weak var pollEditorTable : UITableView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupContainerTopbar()
    }
    
    private func setupContainerTopbar(){
        containerTopBarModel?.title?.text = "CREATE POLL"
        containerTopBarModel?.cameraButton?.isHidden = true
    }
    
}
