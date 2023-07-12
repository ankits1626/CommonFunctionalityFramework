//
//  RemainingLeaderboardConfigurator.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit
import RewardzCommonComponents

struct InitTopLeadersConfiguratorModel {
    let mediaFetcher : CFFMediaCoordinatorProtocol
    let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
}

class RemainingLeaderboardConfigurator:BaseCellConfigurator, LeaderboardCellConfiguratorProtocol{
    
    private weak var eventListener : LeaderboardCellAdapterDelegate?
    private let input : InitTopLeadersConfiguratorModel
    
    init(_ input : InitTopLeadersConfiguratorModel) {
        self.input = input
    }
    
    func registerTableviewToRespectiveCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) {
        inputModel.tableView.register(
            UINib(
                nibName: "RemainingLeaderbaordTableViewCell",
                bundle: Bundle(for: RemainingLeaderbaordTableViewCell.self)
            ),
            forCellReuseIdentifier: "RemainingLeaderbaordTableViewCell"
        )
    }
    
    func getCell(_ inputModel: LeaderboardConfigurationCellDequeueInputModel) -> UITableViewCell {
        return inputModel.tableView.dequeueReusableCell(
            withIdentifier: "RemainingLeaderbaordTableViewCell",
            for: inputModel.indexpath
        )
    }
    
    func configureCell(_ inputModel: LeaderboardCellConfigurationInputModel) throws {
        self.eventListener = inputModel.eventListener
        configureRewardUseNowTableViewCellCell(
            try checkCell(inputModel.cell) as RemainingLeaderbaordTableViewCell,
            datasource: inputModel.datasource,
            indexpath: inputModel.indexpath
        )
    }
    
    func getHeightOfCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) -> CGFloat {
        return 88
    }
    
    private func configureRewardUseNowTableViewCellCell(_ cell : RemainingLeaderbaordTableViewCell, datasource: LeaderboardAdapterDatasource, indexpath : IndexPath){
        cell.remainingUserButton?.tag = indexpath.row + 2
        cell.remainingUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        let data = datasource.getTopGetters(index: indexpath.row + 2)
        let userData = data.getHeroes()[indexpath.row + 2]
        cell.userFullName?.text = userData.getFullName()
        cell.userRankLabel?.text = "\(indexpath.row + 3)"
        cell.userRankLabel?.backgroundColor = UIColor.getControlColor()
        if let unwrappedImage = userData.getProfileImageUrl(),
           !unwrappedImage.absoluteString.isEmpty {
            input.mediaFetcher.fetchImageAndLoad(cell.userProfilePic, imageEndPoint: unwrappedImage)
        }else{
            cell.userProfilePic?.setImageForName(userData.getFullName(), circular: false, textAttributes: nil)
        }
        cell.userDepartment?.text = userData.departmentName
        cell.userAppreciationReceivedLbl?.text = userData.getAppreciationRatio()
    } 
    
    @objc private func editButtonPressed(sender : UIButton){
        eventListener?.getSelectedUserIndexPath(sender)
    }
}



