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
        setupTopUserData(cell: cell)
        for (index,data) in datasource.getTopHeroData().getHeroes().prefix(3).enumerated() {
            self.fillTop3GettersData(index: index, data: data, cell: cell)
        }
        cell.emptyContainerView?.isHidden = datasource.getTopHeroData().getNumberOfHeroes() == 1 ? false : true
        cell.firstUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        cell.secondUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        cell.thirdUserButton?.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
    }
    
    func fillTop3GettersData(index : Int, data : TopRecognitionHero, cell : Top3UsersTableViewCell) {
        switch index {
        case 0:
            cell.userFullName0?.text = data.getFullName()
            cell.firstUserButton?.tag = index
            cell.userRankLabelParentView0?.isHidden = false
            if let unwrappedImage = data.getProfileImageUrl(),
               !unwrappedImage.absoluteString.isEmpty {
                input.mediaFetcher.fetchImageAndLoad(cell.userProfilePic0, imageEndPoint: unwrappedImage)
            }else{
                cell.userProfilePic0?.setImageForName(data.getFullName(), circular: false, textAttributes: nil)
            }
            cell.userDepartment0?.text = data.departmentName
            cell.userReceivedAppreciation0?.text = data.getAppreciationRatio()
        case 1:
            cell.userFullName1?.text = data.getFullName()
            cell.secondUserButton?.tag = index
            cell.userRankLabelParentView1?.isHidden = false
            if let unwrappedImage = data.getProfileImageUrl(),
               !unwrappedImage.absoluteString.isEmpty {
                input.mediaFetcher.fetchImageAndLoad(cell.userProfilePic1, imageEndPoint: unwrappedImage)
            }else{
                cell.userProfilePic1?.setImageForName(data.getFullName(), circular: false, textAttributes: nil)
            }
            cell.userDepartment1?.text = data.departmentName
            cell.userReceivedAppreciation1?.text = data.getAppreciationRatio()
        case 2:
            cell.userFullName2?.text = data.getFullName()
            cell.thirdUserButton?.tag = index
            cell.userRankLabelParentView2?.isHidden = false
            if let unwrappedImage = data.getProfileImageUrl(),
               !unwrappedImage.absoluteString.isEmpty {
                input.mediaFetcher.fetchImageAndLoad(cell.userProfilePic2, imageEndPoint: unwrappedImage)
            }else{
                cell.userProfilePic2?.setImageForName(data.getFullName(), circular: false, textAttributes: nil)
            }
            cell.userDepartment2?.text = data.departmentName
            cell.userReceivedAppreciation2?.text = data.getAppreciationRatio()
        default:
            break
        }
    }
    
    func setupTopUserData(cell : Top3UsersTableViewCell) {
        //need to do cleanup here
        cell.userFullName0?.text = ""
        cell.firstUserButton?.tag = -1
        cell.userRankLabelParentView0?.isHidden = true
        cell.userProfilePic0?.image = UIImage(named: "cff_topGettersPlaceholder")
        cell.userDepartment0?.text = ""
        cell.userReceivedAppreciation0?.text = ""
        
        cell.userFullName1?.text = ""
        cell.secondUserButton?.tag = -1
        cell.userRankLabelParentView1?.isHidden = true
        cell.userProfilePic1?.image = UIImage(named: "cff_topGettersPlaceholder")
        cell.userDepartment1?.text = ""
        cell.userReceivedAppreciation1?.text = ""
        
        cell.userFullName2?.text = ""
        cell.thirdUserButton?.tag = -1
        cell.userRankLabelParentView2?.isHidden = true
        cell.userProfilePic2?.image = UIImage(named: "cff_topGettersPlaceholder")
        cell.userDepartment2?.text = ""
        cell.userReceivedAppreciation2?.text = ""
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
