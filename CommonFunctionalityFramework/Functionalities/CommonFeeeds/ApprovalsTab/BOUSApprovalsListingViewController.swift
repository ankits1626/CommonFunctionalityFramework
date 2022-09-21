//
//  BOUSApprovalsListingViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApprovalsListingViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, PopToRootVc, PopToApprovals {
    
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var jsonDataValues = [BOUSApprovalDataResponseValues]()
    var loader = MFLoader()
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    @IBOutlet weak var approvalView: UIView!
    var statusType : String = ""
    @IBOutlet weak var emptyViewContainer : UIView?
    @IBOutlet weak var selectAllView: UIView!
    var isSelectedAll = false
    var selectedDataArray = [Int]()
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var approvalsCountHolder: NSLayoutConstraint!
    @IBOutlet weak var smallTickImg: UIImageView!
    @IBOutlet weak var selectAllViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var approvalsCountLbl: UILabel!
    @IBOutlet weak var activityLoader: UIActivityIndicatorView!
    var searchText : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        approvalsCountLbl.text = ""
        self.selectAllView.isHidden = true
        self.selectAllViewHeightConstraint.constant = 60
        self.approveBtn.isHidden = true
        self.rejectButton.isHidden = true
        //self.selectAllBtn.setImage(UIImage(named: "small_icon_checkbox_unselected"), for: .normal)
        loadApprovalsList(isFromApproval: false)
        self.approveBtn.backgroundColor = UIColor.getControlColor()
        self.rejectButton.setTitleColor(UIColor.getControlColor(), for: .normal)
        smallTickImg.image = UIImage(named: "small_icon_checkbox_unselected")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //check this
//        self.tabBarController?.tabBar.isHidden = false
//        NotificationCenter.default.post(name: Notification.Name(rawValue: "showMenuButton"), object: nil)
    }
    
    func loadApprovalsList(isFromApproval: Bool){
        self.activityLoader.isHidden = false
        self.activityLoader.startAnimating()
        BOUSGetApprovalsListWorker(networkRequestCoordinator: requestCoordinator).getApprovalsList(searchString: searchText ?? "", nextUrl: "") { (result) in
            DispatchQueue.main.async {
                self.activityLoader.stopAnimating()
                switch result{
                case .Success(result: let response):
                    if let dataValue = response["results"] as? NSArray {
                        print(dataValue)
                    }
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        self.constructData(data: data, isFromApproval: isFromApproval)
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
    
    func constructData(data: Data, isFromApproval: Bool){
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(BOUSApprovalData.self, from: data)
            jsonDataValues =  jsonData.results
            if isFromApproval && jsonDataValues.count > 0{
                NotificationCenter.default.post(name: Notification.Name(rawValue: "approvalsTabStatus"), object: nil, userInfo: [
                    "refreshedCount" : self.jsonDataValues.count
                ])
                return
            }else {
                if jsonDataValues.count == 0 && self.searchText == nil  {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "approvalsTabStatus"), object: nil, userInfo: [
                        "selectedTab" : "received"
                    ])
                    return
                }
            }
            
            DispatchQueue.main.async {
                if self.jsonDataValues.count > 1 {
                    self.approvalsCountLbl.text = "\(self.jsonDataValues.count) Approvals Pending"
                }else {
                    self.approvalsCountLbl.text = "\(self.jsonDataValues.count) Approval Pending"
                }
                
                if self.searchText != nil {
                    self.selectAllView.isHidden = true
                    self.approvalView.isHidden = true
                    self.selectAllViewHeightConstraint.constant = 0
                    self.approvalsCountHolder.constant = 0
                }else {
                    self.approvalView.isHidden = false
                    self.selectAllView.isHidden = false
                }
               
                self.tableView.reloadData()
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonDataValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BOUSApprovalsListTableViewCell
        let dataValue = jsonDataValues[indexPath.row]
        cell.nominatedUserName.text = "\(dataValue.nomination.nominated_team_member.full_name) nominated"
        cell.awardType.text = "\(dataValue.nomination.badges.name)"
        cell.nominatedBy.text = "by \(dataValue.nomination.nominator_name)"
        cell.nominatedDate.text = getCreationDate(jsonData: dataValue)
        if dataValue.time_left.isEmpty {
            cell.timeRemaining.isHidden = true
        }else {
            cell.timeRemaining.text = "\(dataValue.time_left)"
        }
        cell.awardPoints.text = "\(dataValue.nomination.badges.award_points) points"
        cell.userStrengthTitle.text = "\(dataValue.nomination.user_strength.name)"
        cell.userStrengthDescription.text = "\(dataValue.description)"
        cell.usrImg.curvedWithoutBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
        if isSelectedAll {
            if selectedDataArray[indexPath.row] == dataValue.nomination.id {
                cell.usrImg.image = UIImage(named: "New_tick_icon")
                cell.usrImg?.setImageColor(color: UIColor.getControlColor())
            }else {
                mediaFetcher.fetchImageAndLoad(cell.usrImg, imageEndPoint: dataValue.nomination.nominated_team_member.profile_img ?? "")
            }
        }else {
            mediaFetcher.fetchImageAndLoad(cell.usrImg, imageEndPoint: dataValue.nomination.nominated_team_member.profile_img ?? "")
        }
        
        if !dataValue.nomination.badges.icon.isEmpty{
            mediaFetcher.fetchImageAndLoad(cell.awardThumbnail, imageEndPoint: dataValue.nomination.badges.icon)
        }else{
            
            cell.awardThumbnail.image = nil
        }
        return cell
        
    }
    
    func getCreationDate(jsonData : BOUSApprovalDataResponseValues) -> String? {
        if !jsonData.nomination.created.isEmpty{
            let dateInFormate = jsonData.time_left.getdateFromStringFrom(dateFormat: "yyyy-MM-dd")
            return "\(dateInFormate.monthName) \(dateInFormate.day)"
        }else{
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSelectedAll {
            //            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BOUSApprovalsListTableViewCell
            //            let dataValue = jsonDataValues[indexPath.row]
            //            mediaFetcher.fetchImageAndLoad(cell.usrImg, imageEndPoint: dataValue.nomination.nominated_team_member.profile_img ?? "")
            //            if !selectedDataArray.contains(dataValue.nomination.id) {
            //                self.selectedDataArray.insert(dataValue.nomination.id, at: indexPath.row)
            //            }else {
            //                self.selectedDataArray.remove(at: indexPath.row)
            //            }
            //            self.approvalsCountLbl.text = "\(self.selectedDataArray.count) Approvals Selected"
            //
            //            self.tableView.beginUpdates()
            //            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            //            self.tableView.endUpdates()
        }else {
            let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
            let dataValue = jsonDataValues[indexPath.row]
            let controller = storyboard.instantiateViewController(withIdentifier: "BOUSApprovalDetailViewController") as! BOUSApprovalDetailViewController
            controller.selectedNominationId = dataValue.id
            controller.delegate = self
            controller.requestCoordinator = requestCoordinator
            controller.mediaFetcher = mediaFetcher
            self.tabBarController?.tabBar.isHidden = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    @IBAction func selectAllPressed(_ sender: Any) {
        if isSelectedAll {
            self.isSelectedAll = false
            self.selectAllViewHeightConstraint.constant = 60
            self.approveBtn.isHidden = true
            self.rejectButton.isHidden = true
            if self.jsonDataValues.count > 1 {
                self.approvalsCountLbl.text = "\(self.jsonDataValues.count) Approvals Pending"
            }else {
                self.approvalsCountLbl.text = "\(self.jsonDataValues.count) Approval Pending"
            }
            
            smallTickImg.image = UIImage(named: "small_icon_checkbox_unselected")

            //self.selectAllBtn.setImage(UIImage(named: "small_icon_checkbox_unselected"), for: .normal)

            selectedDataArray.removeAll()
            self.tableView.reloadData()
        } else {
            for item in jsonDataValues {
                selectedDataArray.append(item.nomination.id)
            }
            if self.jsonDataValues.count > 1 {
                self.approvalsCountLbl.text = "\(self.jsonDataValues.count) Approvals Selected"
            }else {
                self.approvalsCountLbl.text = "\(self.jsonDataValues.count) Approval Selected"
            }
            smallTickImg.image = UIImage(named: "New_tick_icon")
            smallTickImg.setImageColor(color: UIColor.getControlColor())
           // self.selectAllBtn.setImage(UIImage(named: "New_tick_icon"), for: .normal)
            self.selectAllViewHeightConstraint.constant = 150
            self.approveBtn.isHidden = false
            self.rejectButton.isHidden = false
            self.isSelectedAll = true
            self.tableView.reloadData()
        }
    }
    
    @IBAction func appovalTapped(_ sender: Any) {
        if selectedDataArray.count > 0 {
            let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "BOUSApproveAndRejectNominationViewController") as! BOUSApproveAndRejectNominationViewController
            vc.requestCoordinator = requestCoordinator
            let commmaSeperatedId = (selectedDataArray.map{String($0)}).joined(separator: ",")
            vc.multipleNomination = commmaSeperatedId
            vc.postId = selectedDataArray.first as! Int
            vc.isNominationApproved = true
            vc.delegate = self
            vc.modalPresentationStyle = .overCurrentContext
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while topViewController?.presentedViewController != nil
            {
                topViewController = topViewController?.presentedViewController
            }
            topViewController?.present(vc, animated: false, completion: nil)
        }
        
    }
    
    @IBAction func rejectTapped(_ sender: Any) {
        if selectedDataArray.count > 0 {
            let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
            let vc = storyboard.instantiateViewController(withIdentifier: "BOUSApproveAndRejectNominationViewController") as! BOUSApproveAndRejectNominationViewController
            vc.requestCoordinator = requestCoordinator
            let commmaSeperatedId = (selectedDataArray.map{String($0)}).joined(separator: ",")
            vc.delegate = self
            vc.multipleNomination = commmaSeperatedId
            vc.postId = selectedDataArray.first as! Int
            vc.isNominationApproved = false
            vc.modalPresentationStyle = .overCurrentContext
            var topViewController = UIApplication.shared.keyWindow?.rootViewController
            while topViewController?.presentedViewController != nil
            {
                topViewController = topViewController?.presentedViewController
            }
            topViewController?.present(vc, animated: false, completion: nil)
            
        }
    }
    
    func popToVC() {
        self.isSelectedAll = false
        self.selectAllViewHeightConstraint.constant = 60
        self.approveBtn.isHidden = true
        self.rejectButton.isHidden = true
        loadApprovalsList(isFromApproval: true)
    }
    
    func popToApprovalsAndReload() {
        self.isSelectedAll = false
        self.selectAllViewHeightConstraint.constant = 60
        self.approveBtn.isHidden = true
        self.rejectButton.isHidden = true
        loadApprovalsList(isFromApproval: true)
    }
    
}
