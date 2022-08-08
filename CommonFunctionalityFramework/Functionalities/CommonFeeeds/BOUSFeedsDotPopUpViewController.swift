//
//  BOUSFeedsDotPopUpViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 03/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSFeedsDotPopUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var blurImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImg.isUserInteractionEnabled = true
        blurImg.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
        return cell
    }
    
}
