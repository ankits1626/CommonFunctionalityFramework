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
    var selectedNominationId = Int()
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var loader = MFLoader()
    var jsonDataValues : BOUSApprovalsDetailData!
    var mediaFetcher: CFFMediaCoordinatorProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadApprovalsData()
    }
    
    func loadApprovalsData(){
        self.loader.showActivityIndicator(self.view)
        BOUSGetSelectedApproverWorker(networkRequestCoordinator: requestCoordinator).getApproverData(searchString: "", nextUrl: "", approverId: selectedNominationId) { (result) in
            DispatchQueue.main.async {
                self.loader.hideActivityIndicator(self.view)
                switch result{
                case .Success(result: let response):
                    if let dataValue = response["results"] as? NSArray {
                        print(dataValue)
                    }
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        self.constructData(data: data)
                    }catch {
                        debugPrint(error)
                    }
                case .Failure(let error):
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), message: error.displayableErrorMessage())
                case .SuccessWithNoResponseData:
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("UNEXPECTED RESPONSE", comment: ""))
                }
            }
        }
    }
    
    func constructData(data: Data){
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(BOUSApprovalsDetailData.self, from: data)
            
            jsonDataValues =  jsonData
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loader.hideActivityIndicator(self.view)
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! BOUSApprovalHeaderTableViewCell
            cell.backBtn?.addTarget (self, action: #selector(popVC(_:)), for: UIControl.Event.touchUpInside)
            if jsonDataValues != nil {
                cell.titleLbl.text = jsonDataValues.user_strength.name
                cell.nominatedBy.text = "\(jsonDataValues.nomination.nominated_team_member.full_name) nominated by \(jsonDataValues.created_by_user_info.full_name)"
                cell.dateLbl.text = jsonDataValues.created_on
                mediaFetcher.fetchImageAndLoad(cell.leftImg, imageEndPoint: jsonDataValues.nomination.nominated_team_member.profile_img ?? "")
                mediaFetcher.fetchImageAndLoad(cell.rightImg, imageEndPoint: jsonDataValues.created_by_user_info.profile_img ?? "")
            }
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! BOUSApprovalDescriptionTableViewCell
            if jsonDataValues != nil {
                cell.titleLbl.text = jsonDataValues.description
            }
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! BOUSApprovalAwardLevelTableViewCell
            if jsonDataValues != nil {
                cell.awardType.text = jsonDataValues.nomination.badges.name
                cell.ptsLbl.text = jsonDataValues.nomination.badges.points
                mediaFetcher.fetchImageAndLoad(cell.leftImg, imageEndPoint: jsonDataValues.nomination.badges.icon ?? "")
            }
            return cell
        }else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell4", for: indexPath) as! BOUSApprovalMessageTableViewCell
            if jsonDataValues != nil {
                cell.messageDescription.text = jsonDataValues.nomination.message_to_reviewer
            }
            return cell
        }else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath)
            return cell
        }
    }
    
    @objc func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        let vc = storyboard.instantiateViewController(withIdentifier: "BOUSApproveAndRejectNominationViewController") as! BOUSApproveAndRejectNominationViewController
        vc.requestCoordinator = requestCoordinator
        vc.postId = jsonDataValues.nomination.id
        vc.isNominationApproved = true
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
        let vc = storyboard.instantiateViewController(withIdentifier: "BOUSApproveAndRejectNominationViewController") as! BOUSApproveAndRejectNominationViewController
        vc.requestCoordinator = requestCoordinator
        vc.postId = jsonDataValues.nomination.id
        vc.isNominationApproved = false
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
