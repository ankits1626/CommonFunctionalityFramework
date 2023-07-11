//
//  Top3userCellConfigurator.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit

class Top3userCellConfigurator:BaseCellConfigurator, LeaderboardCellConfiguratorProtocol{
    
    private weak var eventListener : LeaderboardCellAdapterDelegate?
    private let input : InitTopLeadersConfiguratorModel
    
    init(_ input : InitTopLeadersConfiguratorModel) {
        self.input = input
    }
    
    func registerTableviewToRespectiveCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) {
        inputModel.tableView.register(
            UINib(
                nibName: "Top3UsersTableViewCell",
                bundle: Bundle(for: Top3UsersTableViewCell.self)
            ),
            forCellReuseIdentifier: "Top3UsersTableViewCell"
        )
    }
    
    func getCell(_ inputModel: LeaderboardConfigurationCellDequeueInputModel) -> UITableViewCell {
        return inputModel.tableView.dequeueReusableCell(
            withIdentifier: "Top3UsersTableViewCell",
            for: inputModel.indexpath
        )
    }
    
    func configureCell(_ inputModel: LeaderboardCellConfigurationInputModel) throws {
        self.eventListener = inputModel.eventListener
        configureRewardUseNowTableViewCellCell(
            try checkCell(inputModel.cell) as Top3UsersTableViewCell,
            datasource: inputModel.datasource,
            indexpath: inputModel.indexpath
        )
    }
    
    func getHeightOfCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) -> CGFloat {
        if inputModel.datasource.getTopHeroData().getNumberOfHeroes() == 1 {
            return 525
        }
        return 273
    }
    
    private func configureRewardUseNowTableViewCellCell(_ cell : Top3UsersTableViewCell, datasource: LeaderboardAdapterDatasource, indexpath : IndexPath){
        for (index,data) in datasource.getTopHeroData().getHeroes().prefix(3).enumerated() {
            self.fillTop3GettersData(index: index, data: data, cell: cell)
        }
        
        cell.firstUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        cell.secondUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        cell.thirdUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func fillTop3GettersData(index : Int, data : TopRecognitionHero, cell : Top3UsersTableViewCell) {
        switch index {
        case 0:
            cell.userFullName0?.text = data.getFullName()
            cell.firstUserButton?.tag = index
        case 1:
            cell.userFullName1?.text = data.getFullName()
            cell.secondUserButton?.tag = index
        case 2:
            cell.userFullName2?.text = data.getFullName()
            cell.thirdUserButton?.tag = index
        default:
            break
        }
    }
    
    @objc private func editButtonPressed(sender : UIButton){
        eventListener?.getSelectedUserIndexPath(sender)
    }
}

let UnexpectedCellError = NSError(
    domain: "com.rewardz.CellConfigurator",
    code: 1,
    userInfo: [NSLocalizedDescriptionKey: "Asking configurator to configure unexpected cell."]
)

class BaseCellConfigurator {
    
    func checkCell<T>(_ cell: UITableViewCell) throws -> T{
        if let expectedCell = cell as? T{
            return expectedCell
        }else{
            throw UnexpectedCellError
        }
    }
}
