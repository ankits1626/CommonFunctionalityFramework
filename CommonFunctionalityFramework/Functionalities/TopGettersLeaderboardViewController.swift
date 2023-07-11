//
//  TopGettersLeaderboardViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 07/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class TopGettersLeaderboardViewController: UIViewController {
    
    @IBOutlet weak var topGettersTableView : UITableView?
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var loader = MFLoader()
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var filterperiod : String = "overall"
    private var fetchedData = TopHeroesFetchedData()
    @IBOutlet weak var tableViewContainer : UIView?
    @IBOutlet weak var headerView : UIView?
    var themeManager : CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    lazy var filterCoordinators: TopGettersFilterCoordinator = {
        return TopGettersFilterCoordinator()
    }()
    var heroSelectedData : TopGettersFilterOption?
    var recognitionSelectedData : TopGettersFilterOption?
    
    lazy var cellAdapter: LeaderboardCellAdapter = {
        return LeaderboardCellAdapter(
            LeaderboardCellAdapterInputModel(
                delegate: self,
                targetTable: self.topGettersTableView,
                datasource: self,
                networkRequestCoordinator: requestCoordinator,
                mediaFetcher: mediaFetcher
            )
        )
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headerView?.backgroundColor = UIColor.getControlColor()
        self.view.backgroundColor = UIColor.getControlColor()
        self.tableViewContainer?.backgroundColor = UIColor.getControlColor()
        getTopGetters()
    }
    
    
    func getTopGetters() {
        self.loader.showActivityIndicator(self.view)
        TopMonthlyHeroesWorker(filterperiod, networkRequestCoordinator: requestCoordinator).fetchHeroes {[weak self]  (result) in
            DispatchQueue.main.async {
                if let unwrappedSelf = self{
                    print("<<<<<<<<<<<<<<<< fetchHeroesForCategory \(unwrappedSelf)")
                    unwrappedSelf.loader.hideActivityIndicator(unwrappedSelf.view)
                    unwrappedSelf.handleHeroesFetchRespone(result)
                }
            }
        }
    }
    
    private func handleHeroesFetchRespone(_ result : APICallResult<(fetchedHeroes:[TopRecognitionHero], slug: String, userRemainingPoints : Double, userMonthlyAppreciationLimit : Int)>){
        switch result{
        case .Success(let successResult):
            fetchedData.setHeroes(successResult.fetchedHeroes)
            self.topGettersTableView?.backgroundColor = .clear
            self.topGettersTableView?.delegate = self
            self.topGettersTableView?.dataSource = self
            self.topGettersTableView?.reloadData()
        case .SuccessWithNoResponseData:
            ErrorDisplayer.showError(errorMsg: "Unexpected empty response".localized) { (_) in}
        case .Failure(let error):
            ErrorDisplayer.showError(errorMsg: error.displayableErrorMessage()) { (_) in}
        }
    }

    
    @IBAction func backButtonPressed(sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func filterButtonPressed(sender : UIButton) {
        let topGetterVC = TopGettersFilterViewController(filterCoordinator: filterCoordinators, delegate: self)
        self.navigationController?.pushViewController(topGetterVC, animated: true)
    }
}
//MARK: UITableViewDelegate/UITableViewDataSource
extension TopGettersLeaderboardViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellAdapter.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellAdapter.getCell(indexPath)
        cell.selectionStyle = .none
        do{
            try cellAdapter.configureMyActivityCell(cell, indexPath: indexPath)
        }catch let error{
            print("<<<<<<<<<<< Here \(error.localizedDescription)")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        do{
            return try cellAdapter.getHeightForRewardDetailCell(indexPath: indexPath)
        }catch{
            return 0
        }
    }
}

extension TopGettersLeaderboardViewController : LeaderboardAdapterDatasource {
    func getRedemption(index: Int) -> TopHeroesFetchedData {
        return fetchedData
    }
    
    func getTopHeroData() -> TopHeroesFetchedData {
        return fetchedData
    }
    
    func getNumberOfRedemptions() -> Int {
        return fetchedData.getNumberOfHeroes()
    }
}


extension TopGettersLeaderboardViewController : LeaderboardCellAdapterDelegate {
    func getSelectedUserIndexPath(_ sender : UIButton) {
        if sender.tag >= 0 {
            let showSelectedUser = ShowSelectedUserRecognition(nibName: "ShowSelectedUserRecognition", bundle: Bundle(for: ShowSelectedUserRecognition.self))
            showSelectedUser.requestCoordinator = self.requestCoordinator
            showSelectedUser.mediaFetcher = self.mediaFetcher
            showSelectedUser.themeManager = self.themeManager
            showSelectedUser.mainAppCoordinator = self.mainAppCoordinator
            showSelectedUser.feedScreenType = .Received
            self.navigationController?.pushViewController(showSelectedUser, animated: true)
        }
    }
}

extension TopGettersLeaderboardViewController : TopGettersFilterDelegate {
    func finishedFilterSelection(selectedRecognitionType: TopGettersFilterOption?, selectedRecognitionIndex: [Int]?, selectedHeroType: TopGettersFilterOption?, selectedHeroIndex: [Int]?) {
        
        if let unwrappedRecognitionData = selectedRecognitionType {
            recognitionSelectedData = unwrappedRecognitionData
        }
        
        if let unwrappedHeroData = selectedHeroType {
            heroSelectedData = unwrappedHeroData
        }
    }
}
