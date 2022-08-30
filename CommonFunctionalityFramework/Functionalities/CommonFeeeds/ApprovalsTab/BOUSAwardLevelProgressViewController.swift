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

    override func viewDidLoad() {
        super.viewDidLoad()

        blurImage.makeBlurImage(targetImageView: blurImage)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImage.isUserInteractionEnabled = true
        blurImage.addGestureRecognizer(tapGestureRecognizer)
        getHistory()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 400
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
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
            return cell
        }
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
