//
//  BOUSApprovalAwardViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 25/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

protocol SelectAwardLevel {
    func selectedAwardLevel(awardDataSelected : ApprovalAwardCategoryModel,selectedPointsPK : Int)
}

class BOUSApprovalAwardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var blurView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    var awardCategory : [ApprovalAwardCategoryModel] = []
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var delegate : SelectAwardLevel?
    var userSelectedAwardPK : Int!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var loader = MFLoader()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        getCategories()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurView.isUserInteractionEnabled = true
        blurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCategories() {
        self.loader.showActivityIndicator(self.view)
        ApprovalAwardCategoryWorker(networkRequestCoordinator: requestCoordinator).getApproverAwardCategory(){ (results) in
            DispatchQueue.main.async {
                self.loader.hideActivityIndicator(self.view)
                switch results{
                case .Success(result: let awardData):
                    self.awardCategory = awardData
                    self.collectionView?.reloadData()
                case .SuccessWithNoResponseData:
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("UNEXPECTED RESPONSE", comment: ""))
                case .Failure(error: let error):
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), message: error.displayableErrorMessage())
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.awardCategory.count > 0 {
            return self.awardCategory[0].badgeData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                                            for: indexPath) as? BOUSApprovalAwardLevelCollectionViewCell
            else { fatalError("unexpected cell in collection view") }
        let dataSource = self.awardCategory[0].badgeData[indexPath.row]
        cell.awardTitle?.text = dataSource.name
        cell.awardPoints?.text = "\(dataSource.points) Points"
        if dataSource.icon.contains("https://"){
            mediaFetcher.fetchImageAndLoad(cell.logoImg, imageWithCompleteURL: dataSource.icon)
        }else {
            mediaFetcher.fetchImageAndLoad(cell.logoImg, imageEndPoint: dataSource.icon)
        }
      
        if userSelectedAwardPK == dataSource.badgePk {
            cell.tickImg.isHidden = false
            cell.contentView.backgroundColor = UIColor(red: 245, green: 248, blue: 255)
            cell.contentView.curvedUIBorderedControl(borderColor: UIColor.getControlColor(), borderWidth: 1.0, cornerRadius: 8.0)
        }else {
            cell.tickImg.isHidden = true
            cell.contentView.backgroundColor = UIColor(red: 245, green: 255, blue: 255)
            cell.contentView.curvedUIBorderedControl(borderColor:  UIColor(red: 237, green: 240, blue: 255), borderWidth: 1.0, cornerRadius: 8.0)
        }
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataSource = self.awardCategory[0].badgeData[indexPath.row]
        self.userSelectedAwardPK = dataSource.badgePk
        self.collectionView.reloadData()
        var badgeData : [BadgeData] = []
        badgeData.removeAll()
        badgeData.append(dataSource)
        let data = ApprovalAwardCategoryModel(_isMultipleUser: self.awardCategory[0].isMultipleUser, self.awardCategory[0].isSelfEnabled, _isCoreValueEnabled: self.awardCategory[0].isCoreValueEnabled, _parentPK: self.awardCategory[0].parentPK, _badgeData: badgeData)
        delegate?.selectedAwardLevel(awardDataSelected: data, selectedPointsPK: userSelectedAwardPK)
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 98)
    }

}
