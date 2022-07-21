//
//  BOUSApprovalsListingViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApprovalsListingViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var approvalsCountHolder: NSLayoutConstraint!
    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var approvalsCountLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var jsonDataValues = [BOUSApprovalDataResponseValues]()
    var loader = MFLoader()
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        approvalsCountLbl.text = ""
        loadApprovalsList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.post(name: Notification.Name(rawValue: "showMenuButton"), object: nil)
    }
    
    func loadApprovalsList(){
        loader.showActivityIndicator(view)
        BOUSGetApprovalsListWorker(networkRequestCoordinator: requestCoordinator).getApprovalsList(searchString: "", nextUrl: "") { (result) in
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
            let jsonData = try decoder.decode(BOUSApprovalData.self, from: data)
             jsonDataValues =  jsonData.results
//            arrayHolder = []
//            arrayHolder = jsonData.results
            approvalsCountLbl.text = "\(jsonDataValues.count) Approvals Pending"
            DispatchQueue.main.async {
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
        
        mediaFetcher.fetchImageAndLoad(cell.usrImg, imageEndPoint: dataValue.nomination.nominated_team_member.profile_img ?? "")
        
        cell.nominatedUserName.text = "\(dataValue.nomination.nominated_team_member.full_name) nominated"
        mediaFetcher.fetchImageAndLoad(cell.awardThumbnail, imageEndPoint: dataValue.nomination.badges.icon ?? "")
        cell.nominatedBy.text = "\(dataValue.nomination.user_strength.name)"
        cell.awardType.text = "\(dataValue.nomination.badges.name)"
        cell.nominatedBy.text = "by \(dataValue.nomination.nominator_name)"
        cell.nominatedDate.text = "\(dataValue.nomination.created)"
        cell.timeRemaining.text = "\(dataValue.time_left)"
        cell.awardPoints.text = "\(dataValue.nomination.badges.points)"
        cell.userStrengthTitle.text = "\(dataValue.nomination.user_strength.name)"
        cell.userStrengthDescription.text = "\(dataValue.nomination.user_strength.message)"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let dataValue = jsonDataValues[indexPath.row]
        let controller = storyboard.instantiateViewController(withIdentifier: "BOUSApprovalDetailViewController") as! BOUSApprovalDetailViewController
        controller.selectedNominationId = dataValue.id
        controller.requestCoordinator = requestCoordinator
        controller.mediaFetcher = mediaFetcher
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func selectAllPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: "BOUSApproveRejectPopViewController") as! BOUSApproveRejectPopViewController
        vc.modalPresentationStyle = .overCurrentContext
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil
        {
          topViewController = topViewController?.presentedViewController
        }
        topViewController?.present(vc, animated: false, completion: nil)
    }
}
