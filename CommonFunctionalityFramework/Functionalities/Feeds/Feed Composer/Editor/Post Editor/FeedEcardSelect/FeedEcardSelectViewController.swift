//
//  FeedEcardSelectViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

protocol DidTapOnEcard {
    func selectedEcard(ecardData: EcardListResponseValues,selectedEcardPk : Int)
}

import UIKit
import RewardzCommonComponents

class FeedEcardSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var orgHeaderView: UIView!
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    weak var mediaFetcher: CFFMediaCoordinatorProtocol?

    var arrayHolder = [EcardCategoryResponseValues]()
    var selectedTab = ""
    let loader = MFLoader()
    var selectedIndex = 0
    var arrayListHolder = [EcardListResponseValues]()
    var selectedCategory: Int!
    var delegate: DidTapOnEcard?
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let imageView = UIImageView(image: UIImage(named: "searchnewicon"))
            imageView.contentMode = UIView.ContentMode.center
            imageView.frame = CGRect(x: 0.0, y: 0.0, width: imageView.image!.size.width + 15.0, height: imageView.image!.size.height)
            searchBar.searchTextField.leftViewMode = UITextField.ViewMode.always
            searchBar.searchTextField.leftView = imageView
            searchBar.searchTextField.curvedCornerControl()
        } else {
            
        }
    
        self.orgHeaderView.backgroundColor = UIColor.getControlColor()
        searchBar.delegate = self
        GetEcardCategoryFormWorker(networkRequestCoordinator: self.requestCoordinator).getGetEcardCategory() { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(result: let response):
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        self.constructData(data: data)
                        self.selectedCategory = self.arrayHolder[0].pk
                        self.loadData(category: self.selectedCategory ,searchString: "", nextURL: "")
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
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: UIScreen.main.bounds.height)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedsComposerDrawerError.UnableToGetTopViewController
        }
    }
    
    func loadData(category: Int, searchString: String, nextURL: String) {
      //  self.loader.showActivityIndicator(self.view)
        GetEcardWorker(networkRequestCoordinator: self.requestCoordinator).getEcard(
            categoryId: category,
            searchString: searchString,
            nextUrl: nextURL) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(result: let response):
                    if let nextUrl = response["next"] as? String {
                       // self.nextPageUrl = nextUrl
                    } else {
                       // self.nextPageUrl = ""
                    }
                    do {
                        let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                        self.constructListData(data: data)
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
            let jsonData = try decoder.decode(EcardCategory.self, from: data)
            arrayHolder = []
            arrayHolder = jsonData.results
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.loader.hideActivityIndicator(self.view)
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    func constructListData(data: Data){
        self.loader.showActivityIndicator(self.view)
        do {
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(EcardList.self, from: data)
            arrayListHolder = jsonData.results
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.loader.hideActivityIndicator(self.view)
            }
        } catch {
            print("error:\(error)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayHolder.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BOUSEcardCategoryListCollectionViewCell
        let dataValues = arrayHolder[indexPath.row]
        cell.layer.cornerRadius = 8.0
        cell.TxtLbl.text = dataValues.name
        if selectedIndex == indexPath.row {
            cell.backgroundColor = UIColor.getControlColor()
            cell.TxtLbl.textColor = UIColor.white
        }else {
            cell.backgroundColor = UIColor.white
            cell.TxtLbl.textColor = UIColor.gray
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        self.selectedCategory = self.arrayHolder[indexPath.row].pk
        self.collectionView.reloadData()
        self.loadData(category: self.selectedCategory, searchString: "", nextURL: "")
        self.tableView.reloadData()
        //           self.tableView.reloadData()
        //            self.fecthContacts(searchKey: nil, selectedTabType: selectedTab)
        //            self.tableView.scrollsToTop = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayListHolder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BOUSEcardListTableViewCell
        let dataVal = arrayListHolder[indexPath.row]
        mediaFetcher!.fetchImageAndLoad(cell.imgHolder, imageEndPoint: URL(string: dataVal.image))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataVal = arrayListHolder[indexPath.row]
        delegate!.selectedEcard(ecardData: dataVal, selectedEcardPk: self.selectedCategory)
        self.dismiss(animated: true)
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
        self.dismiss(animated: true)
    }
}


extension FeedEcardSelectViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if searchBar.text?.count != 0 {
            if let searchText = searchBar.text {
                let urlString = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                loadData(category: self.selectedCategory, searchString: urlString!, nextURL: "")
            }
        }else {
            arrayHolder = []
            loadData(category: self.selectedCategory, searchString: "", nextURL: "")
        }
    }
}
