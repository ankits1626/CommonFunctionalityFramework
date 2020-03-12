//
//  BaseEditorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class BaseEditorViewController: UIViewController {
    var containerTopBarModel : EditorContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupContainerTopbar(){
        containerTopBarModel?.title?.text = ""
        containerTopBarModel?.cameraButton?.setImage(
            UIImage(named: "camera", in: Bundle(for: BaseEditorViewController.self), compatibleWith: nil),
            for: .normal
        )
        containerTopBarModel?.cameraButton?.tintColor = .black
        containerTopBarModel?.cameraButton?.addTarget(self, action: #selector(initiateMediaAttachment), for: .touchUpInside)
    }
    
    @objc private func initiateMediaAttachment(){
        
    }
    
}
