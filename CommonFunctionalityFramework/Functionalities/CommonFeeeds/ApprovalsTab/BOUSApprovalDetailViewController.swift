//
//  BOUSApprovalDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

protocol PopToApprovals {
    func popToApprovalsAndReload()
}


class BOUSApprovalDetailViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, PopToRootVc {
    
    @IBOutlet weak var approvalTxt: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var approveButton : UIButton?
    @IBOutlet weak var rejectButton : UIButton?
    @IBOutlet weak var messageContainerView : UIView?
    @IBOutlet weak var approveButtonConstraints : NSLayoutConstraint?
    @IBOutlet weak var rejectButtonConstraints : NSLayoutConstraint?
    @IBOutlet weak var messageContainerViewConstraints : NSLayoutConstraint?
    
    var selectedNominationId = Int()
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var loader = MFLoader()
    var jsonDataValues : BOUSApprovalsDetailData!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var isComingFromNominationPage : Bool = false
    var delegate : PopToApprovals?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadApprovalsData()
    }
    
    func setupView() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        approveButton?.isHidden = isComingFromNominationPage
        rejectButton?.isHidden = isComingFromNominationPage
        messageContainerView?.isHidden = true
        approveButtonConstraints?.constant = isComingFromNominationPage ? 0 :  48
        rejectButtonConstraints?.constant = isComingFromNominationPage ? 0 :  48
        messageContainerViewConstraints?.constant = isComingFromNominationPage ? 0 : 51
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! BOUSApprovalHeaderTableViewCell
            cell.backBtn?.addTarget (self, action: #selector(popVC(_:)), for: UIControl.Event.touchUpInside)
            if jsonDataValues != nil {
                cell.titleLbl.text = jsonDataValues.user_strength.name
                cell.leftName.text = "\(jsonDataValues.nomination.nominated_team_member.full_name)"
                cell.rightName.text = "\(jsonDataValues.created_by_user_info.full_name)"
                cell.dateLbl.text =  getCreationDate(jsonDate: jsonDataValues.created_on)
                
                cell.contentView.backgroundColor = Rgbconverter.HexToColor(jsonDataValues.nomination.badges.background_color,alpha:  0.1)
                
                if let leftImg = jsonDataValues.nomination.nominated_team_member.profile_img as? String, leftImg.count > 0 {
                     mediaFetcher.fetchImageAndLoad(cell.leftImg, imageEndPoint: leftImg)
                }else{
                    cell.leftImg.setImageForName(jsonDataValues.nomination.nominated_team_member.full_name, circular: false, textAttributes: nil)
                }
                
                if let rightImage = jsonDataValues.created_by_user_info.profile_img as? String, rightImage.count > 0 {
                    mediaFetcher.fetchImageAndLoad(cell.rightImg, imageEndPoint: jsonDataValues.created_by_user_info.profile_img ?? "")
                    
                }else{
                    cell.rightImg.setImageForName(jsonDataValues.created_by_user_info.full_name, circular: false, textAttributes: nil)
                }
            }
            return cell
        }else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! BOUSApprovalDescriptionTableViewCell
            if jsonDataValues != nil {
                if let unwrappedText = jsonDataValues.description as? String{
                    let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: Int64(jsonDataValues.nomination.id), description: unwrappedText)
                    ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                        cell.titleLbl.text = nil
                        cell.titleLbl.attributedText = attr
                    })
                }else{
                    cell.titleLbl.text = jsonDataValues.description
                }
            }
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! BOUSApprovalAwardLevelTableViewCell
            if jsonDataValues != nil {
                cell.awardType.text = jsonDataValues.nomination.badges.name
                cell.ptsLbl.text = "\(jsonDataValues.nomination.badges.award_points) Points"
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
    
    func getCreationDate(jsonDate: String) -> String? {
        if !jsonDate.isEmpty{
            let dateInFormate = jsonDate.getdateFromStringFrom(dateFormat: "yyyy-MM-dd")
            return "\(dateInFormate.monthName) \(dateInFormate.day)"
        }
        return ""
    }
    
    @objc func popVC(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        }else if indexPath.row == 1 {
            return UITableView.automaticDimension
        }else if indexPath.row == 2 {
            return 82
        }else if indexPath.row == 3 {
            return UITableView.automaticDimension
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
        vc.delegate = self
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
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil
        {
            topViewController = topViewController?.presentedViewController
        }
        topViewController?.present(vc, animated: false, completion: nil)
    }
    
    func popToVC() {
        self.navigationController?.popToRootViewController(animated: false)
        delegate?.popToApprovalsAndReload()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
