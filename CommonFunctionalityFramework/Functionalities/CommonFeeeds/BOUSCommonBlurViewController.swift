//
//  BOUSCommonBlurViewController.swift
//  SKOR
//
//  Created by Puneeeth on 29/06/22.
//  Copyright © 2022 Rewradz Private Limited. All rights reserved.
//

import UIKit

class BOUSCommonBlurViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }

}
