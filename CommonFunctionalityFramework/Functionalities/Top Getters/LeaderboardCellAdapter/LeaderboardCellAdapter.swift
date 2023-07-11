//
//  LeaderboardCellAdapter.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit

class LeaderboardCellAdapter{
    private var cachedConfigurators = [LeaderboardCellType: LeaderboardCellConfiguratorProtocol]()
    private let inputModel : LeaderboardCellAdapterInputModel
    
    init(_ input : LeaderboardCellAdapterInputModel) {
        self.inputModel = input
        setupTableview()
    }
    
    func getCell(_ indexpath: IndexPath) -> UITableViewCell{
        do{
            return try getCachedConfiguratorOrCreateNew(try getCellType(indexpath)).getCell(
                LeaderboardConfigurationCellDequeueInputModel(
                    indexpath: indexpath,
                    tableView: inputModel.targetTable,
                    datasource: inputModel.datasource
                )
            )
        }catch {
            return UITableViewCell()//[TBD]: will be refactored for better error handling
        }
    }
    
    func configureMyActivityCell(_ cell : UITableViewCell, indexPath: IndexPath) throws {
        try getCachedConfiguratorOrCreateNew(try getCellType(indexPath))
            .configureCell(
                LeaderboardCellConfigurationInputModel(
                    cell: cell,
                    eventListener: inputModel.delegate,
                    tableView: inputModel.targetTable,
                    datasource: inputModel.datasource,
                    indexpath: indexPath
                )
        )
    }
    
    func getHeightForRewardDetailCell(indexPath: IndexPath) throws -> CGFloat {
        return try getCachedConfiguratorOrCreateNew(try getCellType(indexPath))
            .getHeightOfCell(
                LeaderboardCellConfigurationBaseInputModel(
                    tableView: inputModel.targetTable,
                    datasource: inputModel.datasource
                )
        )
    }
    
    func getNumberOfRows() -> Int {
        return inputModel.datasource.getNumberOfRedemptions()
    }
    
    deinit {
        print("************** LeaderboardCellAdapter deinitialized")
    }
}


extension LeaderboardCellAdapter{
    private func setupTableview(){
        LeaderboardCellType.allCases.forEach { (type) in
            do{
                try getCachedConfiguratorOrCreateNew(type).registerTableviewToRespectiveCell(
                    LeaderboardCellConfigurationBaseInputModel(
                        tableView: inputModel.targetTable,
                        datasource: inputModel.datasource
                    )
                )
            }catch{
                print("************* configurator not available for \(type)")
            }
        }
    }
    
    private func getCellType(_ indexPath: IndexPath) throws -> LeaderboardCellType{
        switch indexPath.row {
        case 0:
            return .Top3User
        default:
            return .Remaining
        }
    }
    
    private func getCachedConfiguratorOrCreateNew(_ cellType: LeaderboardCellType) throws -> LeaderboardCellConfiguratorProtocol{
        var cachedConfigurator : LeaderboardCellConfiguratorProtocol! = cachedConfigurators[cellType]
        if cachedConfigurator == nil{
            cachedConfigurator = try cellType.getCellConfigurator(mediaFetcher: inputModel.mediaFetcher, networkRequestCoordinator: inputModel.networkRequestCoordinator)
            cachedConfigurators[cellType] = cachedConfigurator
        }
        return cachedConfigurator
    }
}

