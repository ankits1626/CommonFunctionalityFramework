//
//  FeedContentCoordinatorProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol FeedCellTypeProtocol {
    var cellNib : UINib?{get}
    var cellIdentifier : String {get}
}

protocol FeedCellCoordinatorProtocol {
    var cellType : FeedCellTypeProtocol {get}
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell
    func loadDataCell(_ inputModel: FeedCellLoadDataModel)
    func getHeight(_ inputModel: FeedCellGetHeightModel) -> CGFloat
}

extension FeedCellCoordinatorProtocol{
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
}

struct FeedContentGetCellModel {
    var targetIndexpath : IndexPath
}

struct FeedContentConfigureCellModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
    var delegate : FeedsDelegate
    weak var selectedoptionMapper : SelectedPollAnswerMapper?
}

struct FeedContentGetHeightOfCellModel {
    var targetIndexpath : IndexPath
}

protocol FeedContentCoordinatorProtocol {
    var feedsDataSource : FeedsDatasource! {set get}
    func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? )
    func getRowsToRepresentAFeed(feedIndex : Int) -> [FeedCellTypeProtocol]
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell
    func configureCell(_ inputModel: FeedContentConfigureCellModel)
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat
}
