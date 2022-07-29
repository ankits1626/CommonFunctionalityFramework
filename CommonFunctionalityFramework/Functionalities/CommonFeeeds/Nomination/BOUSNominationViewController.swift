//
//  BOUSNominationViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class BOUSNominationViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var selectAllBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var jsonDataValues = [BOUSApprovalDataResponseValues]()
    var loader = MFLoader()
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var statusType : String = ""
    @IBOutlet weak var emptyViewContainer : UIView?
    lazy private var emptyResultView: NoEntryViewController = {
        return NoEntryViewController(
            nibName: "NoEntryViewController",
            bundle: Bundle(for: NoEntryViewController.self)
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadApprovalsList()
    }
        
    func loadApprovalsList(){
        self.view.showBlurLoader()
        GetBOUSNominationWorker(networkRequestCoordinator: requestCoordinator).getNominationList(statusType: statusType, nextUrl: "")  { (result) in
            DispatchQueue.main.async {
                self.view.removeBluerLoader()
                switch result{
                case .Success(result: let response):
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
            if jsonDataValues.count == 0 {
                var emptyMessage : String!
                emptyMessage = "Opps! You dont have any nomination in \(statusType)."
                self.emptyResultView.showEmptyMessageView(
                    message: emptyMessage,
                    parentView: self.emptyViewContainer!,
                    parentViewController: self
                )
            }else{
                self.emptyResultView.hideEmptyMessageView()
            }
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
        if !dataValue.nomination.nominated_team_member.profile_img.isEmpty{
            mediaFetcher.fetchImageAndLoad(cell.usrImg, imageEndPoint: dataValue.nomination.nominated_team_member.profile_img)
        }else{
            cell.usrImg.image = nil
        }
        
        if !dataValue.nomination.badges.icon.isEmpty{
            mediaFetcher.fetchImageAndLoad(cell.awardThumbnail, imageEndPoint: dataValue.nomination.badges.icon)
        }else{
            cell.awardThumbnail.image = nil
        }
        
        
        cell.nominatedUserName.attributedText =  getCreatorName(text: "For", userName: "\(dataValue.nomination.nominated_team_member.full_name)")
        cell.nominatedDate.text = getCreationDate(jsonData: dataValue)
        cell.userStrengthTitle.text = "\(dataValue.nomination.user_strength.name)"
        
        
        if let unwrappedText = dataValue.description as? String{
            let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: Int64(dataValue.id), description: unwrappedText)
            ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                cell.userStrengthDescription?.text = nil
                cell.userStrengthDescription?.attributedText = attr
            })
        }else{
            cell.userStrengthDescription.text = dataValue.description
        }
        cell.awardType.text = "\(dataValue.nomination.badges.name)"
        cell.awardPoints.text = "\(dataValue.nomination.badges.award_points) Points"
        cell.timeRemaining.text = "\(dataValue.nomination.nom_status)"
        cell.timeRemaining.curvedWithoutBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 6.0)
        cell.timeRemaining.backgroundColor = Rgbconverter.HexToColor(dataValue.nomination.nom_status_color, alpha: 0.1)
        cell.timeRemaining.textColor = Rgbconverter.HexToColor(dataValue.nomination.nom_status_color, alpha: 1.0)
        cell.usrImg.curvedWithoutBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 210
    }
    func getCreatorName(text : String , userName : String) -> NSAttributedString{
        let referenceText = text + " "
        let authorName = userName
        let attributedString = NSMutableAttributedString(string: "\(referenceText)\(authorName)",
                                                         attributes: [
                                                            .font: UIFont.systemFont(ofSize: 14.0, weight: .bold),
                                                            .foregroundColor: UIColor(red: 21, green: 21, blue: 21),
                                                            .kern: 0.39
                                                         ])
        attributedString.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 14.0, weight: .regular),
            range: NSRange(location: 0, length: referenceText.length)
        )
        return attributedString
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
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let dataValue = jsonDataValues[indexPath.row]
        let controller = storyboard.instantiateViewController(withIdentifier: "BOUSApprovalDetailViewController") as! BOUSApprovalDetailViewController
        controller.isComingFromNominationPage = true
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

extension String {
    var length : Int {
        return self.count
    }
}

