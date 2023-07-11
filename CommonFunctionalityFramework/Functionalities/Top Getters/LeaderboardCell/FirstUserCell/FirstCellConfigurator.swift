//
//  FirstCellConfigurator.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit

struct InitTopLeadersConfiguratorModel {
    let mediaFetcher : CFFMediaCoordinatorProtocol
    let networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
}

class FirstCellConfigurator:BaseCellConfigurator, LeaderboardCellConfiguratorProtocol{
    
    private weak var eventListener : LeaderboardCellAdapterDelegate?
    private let input : InitTopLeadersConfiguratorModel
    
    init(_ input : InitTopLeadersConfiguratorModel) {
        self.input = input
    }
    
    func registerTableviewToRespectiveCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) {
        inputModel.tableView.register(
            UINib(
                nibName: "FirstUserTableViewCell",
                bundle: Bundle(for: FirstUserTableViewCell.self)
            ),
            forCellReuseIdentifier: "FirstUserTableViewCell"
        )
    }
    
    func getCell(_ inputModel: LeaderboardConfigurationCellDequeueInputModel) -> UITableViewCell {
        return inputModel.tableView.dequeueReusableCell(
            withIdentifier: "FirstUserTableViewCell",
            for: inputModel.indexpath
        )
    }
    
    func configureCell(_ inputModel: LeaderboardCellConfigurationInputModel) throws {
        self.eventListener = inputModel.eventListener
        configureRewardUseNowTableViewCellCell(
            try checkCell(inputModel.cell) as FirstUserTableViewCell,
            datasource: inputModel.datasource,
            indexpath: inputModel.indexpath
        )
    }
    
    func getHeightOfCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) -> CGFloat {
        return 104
    }
    
    private func configureRewardUseNowTableViewCellCell(_ cell : FirstUserTableViewCell, datasource: LeaderboardAdapterDatasource, indexpath : IndexPath){
        print("First ****** \(indexpath.row + 2)")
        
        cell.firstUserButton?.tag = indexpath.row + 2
        cell.firstUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        let data = datasource.getRedemption(index: indexpath.row + 2)
        cell.userFullName?.text = data.getHeroes()[indexpath.row + 2].getFullName()
        cell.userRankLabel?.text = "\(indexpath.row + 2)"
        cell.userRankLabel?.backgroundColor = UIColor.getControlColor()
    }
    
    @objc private func editButtonPressed(sender : UIButton){
        eventListener?.getSelectedUserIndexPath(sender)
    }
}


