//
//  BOUSReactionsListViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSReactionsListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var tableViewArrayHolder = [BOUSReactionListDataResponseValues]()
    var collectionViewArrayHolder = [BOUSReactionCountDataResponseValues]()
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var loader = MFLoader()
    var selectedIndex = 0
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var postId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData(reaction: "")
    }
    
    func loadData(reaction: String) {
        BOUSGetReactionListWorker(networkRequestCoordinator: requestCoordinator).getReactionList(postId: postId, reactionId: reaction, nextUrl: "") { (result) in
            DispatchQueue.main.async {
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
        self.loader.showActivityIndicator(self.view)
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(BOUSReactionsListData.self, from: data)
            self.tableViewArrayHolder.removeAll()
            self.collectionViewArrayHolder.removeAll()
            tableViewArrayHolder = jsonData.results
            collectionViewArrayHolder = jsonData.counts
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.collectionView.reloadData()
                self.loader.hideActivityIndicator(self.view)
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewArrayHolder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BOUSReactionsCategoryCollectionViewCell
        cell.layer.cornerRadius = 8.0
        
//        if indexPath.row == 0 {
//            cell.TxtLbl.text = "All \(collectionViewArrayHolder.count)"
//            cell.leftImg.isHidden = true
//        }else {
            let dataValues = collectionViewArrayHolder[indexPath.row]

            if dataValues.reaction_type == 7 {
                cell.leftImg.isHidden = true
                cell.TxtLbl.text = "All \(dataValues.reaction_count)"
            }else {
                cell.TxtLbl.text = "\(dataValues.reaction_count)"
                cell.leftImg.isHidden = false
                if dataValues.reaction_type == 0 {
                    cell.leftImg.image = UIImage(named: "like")
                }else if dataValues.reaction_type == 1 {
                    cell.leftImg.image = UIImage(named: "love")
                }else if dataValues.reaction_type == 2 {
                    cell.leftImg.image = UIImage(named: "clap")
                }else if dataValues.reaction_type == 3 {
                    cell.leftImg.image = UIImage(named: "support")
                }else if dataValues.reaction_type == 4 {
                    cell.leftImg.image = UIImage(named: "celebrate")
                }
            }
    
     //   }
        
        if selectedIndex == indexPath.row {
            cell.backgroundColor = #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1)
            cell.TxtLbl.textColor = .white
        }else {
            cell.backgroundColor = .white
            cell.TxtLbl.textColor = .gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataValues = collectionViewArrayHolder[indexPath.row]
        selectedIndex = indexPath.row
        if dataValues.reaction_type == 7 {
            self.loadData(reaction: "")
        }else {
            self.loadData(reaction: "\(dataValues.reaction_type)")
        }
        self.tableView.scrollsToTop = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewArrayHolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BOUSReactionListTableViewCell
        let dataVal = tableViewArrayHolder[indexPath.row]
        mediaFetcher.fetchImageAndLoad(cell.userImg, imageEndPoint: dataVal.user_info.profile_img ?? "")
        cell.userName.text = dataVal.user_info.full_name
        cell.userInfo.text = dataVal.user_info.departments[0].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        let dataVal = arrayListHolder[indexPath.row]
        //        self.navigationController?.popViewController(animated: true)
        // delegate!.selectedEcard(ecardData: dataVal, selectedEcardPk: self.selectedCategory)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 147
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 12
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 10    //if you want round edges
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
        cell.layer.cornerRadius = 8.0
        cell.layer.mask = maskLayer
    }
    
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
