//
//  BOUSAwardLevelProgressViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 13/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSAwardLevelProgressViewController: UIViewController,UITableViewDelegate,UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurImage: UIImageView!
    let loader = MFLoader()
    var nominationId:Int!
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var arrayHolder = [BOUSApprovalHistoryDataResponseValues]()
    @IBOutlet weak var holderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        blurImage.makeBlurImage(targetImageView: blurImage)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImage.isUserInteractionEnabled = true
        blurImage.addGestureRecognizer(tapGestureRecognizer)
        getHistory()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
        self.holderView.layer.cornerRadius = 8.0
        self.tableView.allowsSelection = false
    }
    
    func getHistory() {
        self.loader.showActivityIndicator(self.view)
        BOUSGetAprrovalAwardHistoryWorker(networkRequestCoordinator: requestCoordinator).getApproverAwardHistoryData(nominationId: nominationId) { (result) in
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
            let jsonData = try decoder.decode(BOUSApprovalHistory.self, from: data)
            arrayHolder = jsonData.results
            print(arrayHolder.count)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loader.hideActivityIndicator(self.view)
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayHolder.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
////        if indexPath.row == 1 {
////            return 215
////        }else {
////            return 106
////        }
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dataValues = arrayHolder[indexPath.row]
        if dataValues.action == "created" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! BOUSAwardLevelNominationTableViewCell
            cell.userName.text = dataValues.actor.first_name  + dataValues.actor.last_name
            cell.department.text = dataValues.actor.department_name
            if let Img = dataValues.actor.profile_pic_url as? String, Img.count > 0 {
                 mediaFetcher.fetchImageAndLoad(cell.userImg, imageEndPoint: Img)
            }else{
                let fullName = dataValues.actor.first_name + dataValues.actor.last_name
                cell.userImg.setImageForName(fullName, circular: false, textAttributes: nil)
            }
            
            cell.date.text = getCreationDate(jsonDate: dataValues.timestamp ?? "")
            
            return cell
        }
        
        if dataValues.action == "updated" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! BOUSAwardLevel1TableViewCell
            cell.userName.text = dataValues.actor.first_name + dataValues.actor.last_name
            cell.department.text = dataValues.actor.department_name
            cell.awardLevelStatus.text =  dataValues.status ?? ""
            if let nom_color = dataValues.nom_status_color {
                cell.awardLevelStatus.backgroundColor = Rgbconverter.HexToColor(nom_color, alpha: 0.1)
                cell.awardLevelStatus.textColor = Rgbconverter.HexToColor(nom_color, alpha: 1.0)
            }
            if let level = dataValues.level as? Int{
                cell.levelNumber.text = "\("Level".localized) \(level)"
            }else {
                cell.levelNumber.text = "Level".localized
            }
            if dataValues.changes?.badges == nil {
                cell.awardLevelStackView.isHidden = true
            }else {
                let attributedText = NSAttributedString(
                    string: "\(dataValues.changes?.badges?.old_badge ?? "")",
                    attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                )
                cell.leftAwardLevel.attributedText = attributedText
                cell.rightAwardLevel.text = " > " + "\(dataValues.changes?.badges?.new_badge ?? "")"
            }
            if dataValues.changes?.shared_with == nil {
                cell.privacyLevelStackView.isHidden = true
            }else {
                let attributedText = NSAttributedString(
                    string: "\(dataValues.changes?.shared_with?.old ?? "")",
                    attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
                )
                cell.leftPrivacyLevel.attributedText = attributedText
                cell.rightPrivacyLevel.text = " > " + "\(dataValues.changes?.shared_with?.new ?? "")"
            }
            
            if let Img = dataValues.actor.profile_pic_url as? String, Img.count > 0 {
                 mediaFetcher.fetchImageAndLoad(cell.userImg, imageEndPoint: Img)
            }else{
                let fullName = dataValues.actor.first_name + dataValues.actor.last_name
                cell.userImg.setImageForName(fullName, circular: false, textAttributes: nil)
            }
            cell.date.text =  getCreationDate(jsonDate: dataValues.timestamp ?? "")

            return cell
        }
        
        if dataValues.action == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! BOUSAwardPendingTableViewCell
            cell.userName.text = dataValues.actor.first_name + dataValues.actor.last_name
            cell.department.text = dataValues.actor.department_name
            cell.holderView.layer.borderColor = #colorLiteral(red: 0.9248943925, green: 0.9362992644, blue: 0.9943410754, alpha: 1)
            cell.holderView.layer.borderWidth = 1.0
            cell.holderView.layer.cornerRadius = 8.0
            if let Img = dataValues.actor.profile_pic_url as? String, Img.count > 0 {
                 mediaFetcher.fetchImageAndLoad(cell.userImg, imageEndPoint: Img)
            }else{
                let fullName = dataValues.actor.first_name + dataValues.actor.last_name
                cell.userImg.setImageForName(fullName, circular: false, textAttributes: nil)
            }
            if let level = dataValues.level as? Int{
                cell.levelTitle.text = "\("Level".localized) \(level)"
            }else {
                cell.levelTitle.text = "Level".localized
            }
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! BOUSAwardPendingTableViewCell
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

}

extension UIImageView
{
    func makeBlurImage(targetImageView:UIImageView?)
    {
        var blurEffect = UIBlurEffect()
        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemThickMaterialDark)
        } else {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds
        blurEffectView.alpha = 0.7
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        targetImageView?.addSubview(blurEffectView)
    }
}
