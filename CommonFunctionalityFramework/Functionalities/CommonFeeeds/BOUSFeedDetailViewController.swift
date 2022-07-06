//
//  BOUSFeedDetailViewController.swift
//  SKOR
//
//  Created by Puneeeth on 29/06/22.
//  Copyright © 2022 Rewradz Private Limited. All rights reserved.
//

import UIKit

class BOUSFeedDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var addComment: UITextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath)
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            return cell
        }
    }
    

    @IBAction func backPressed(_ sender: Any) {
    }

    @IBAction func postCommentPressed(_ sender: Any) {
    }
    
    
}
