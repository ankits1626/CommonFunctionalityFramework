//
//  BOUSApprovalDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApprovalDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var approvalTxt: UITextField!
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
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            return cell
        }else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath)
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }else if indexPath.row == 1 {
            return 89
        }else if indexPath.row == 2 {
            return 82
        }else if indexPath.row == 3 {
            return 152
        }else {
            return 48
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 4 {
            let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "BOUSAwardLevelProgressViewController") as! BOUSAwardLevelProgressViewController
            //self.navigationController?.pushViewController(controller, animated: true)
            
            vc.modalPresentationStyle = .overCurrentContext
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while topViewController?.presentedViewController != nil
            {
              topViewController = topViewController?.presentedViewController
            }
            topViewController?.present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func appovalTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "BOUSAwardLevelProgressViewController") as! BOUSAwardLevelProgressViewController
        //self.navigationController?.pushViewController(controller, animated: true)
        
        vc.modalPresentationStyle = .overCurrentContext
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil
        {
          topViewController = topViewController?.presentedViewController
        }
        topViewController?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func rejectTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "BOUSAwardLevelProgressViewController") as! BOUSAwardLevelProgressViewController
        //self.navigationController?.pushViewController(controller, animated: true)
        
        vc.modalPresentationStyle = .overCurrentContext
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil
        {
          topViewController = topViewController?.presentedViewController
        }
        topViewController?.present(vc, animated: false, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
