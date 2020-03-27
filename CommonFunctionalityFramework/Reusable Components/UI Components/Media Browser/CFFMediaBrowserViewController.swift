//
//  CFFMediaBrowserViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 27/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class CFFMediaBrowserViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction private func closeBowser(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func downloadMedia(){
    }
}
