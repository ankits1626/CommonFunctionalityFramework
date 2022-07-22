//
//  CommonFeedContentCoordinatorProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 03/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

protocol CommonFeedCellTypeProtocol {
    var cellNib : UINib?{get}
    var cellIdentifier : String {get}
}

protocol CommonFeedCellCoordinatorProtocol {
    var cellType : CommonFeedCellTypeProtocol {get}
    func getCell(_ inputModel: CommonFeedCellDequeueModel) -> UITableViewCell
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel)
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat
}

extension CommonFeedCellCoordinatorProtocol{
    func getCell(_ inputModel: CommonFeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
}


struct CommonFeedContentConfigureCellModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
    var delegate : CommonFeedsDelegate
    weak var selectedoptionMapper : SelectedPollAnswerMapper?
    weak var themeManager: CFFThemeManagerProtocol?
    weak var networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol?
}

protocol CommonFeedContentCoordinatorProtocol {
    var feedsDataSource : CommonFeedsDatasource! {set get}
    func registerTableViewForAllPossibleCellTypes(_ tableView : UITableView? )
    func getRowsToRepresentAFeed(feedIndex : Int) -> [CommonFeedCellTypeProtocol]
    func getCell(_ inputModel: FeedContentGetCellModel) -> UITableViewCell
    func configureCell(_ inputModel: CommonFeedContentConfigureCellModel)
    func getHeightOfCell(_ inputModel: FeedContentGetHeightOfCellModel) -> CGFloat
}


struct CommonFeedCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    var datasource: CommonFeedsDatasource
    var isFeedDetailPage : Bool
    weak var themeManager: CFFThemeManagerProtocol?
    weak var networkRequestCoordinator : CFFNetworkRequestCoordinatorProtocol?
}

struct CommonFeedCellLoadDataModel {
    var targetIndexpath : IndexPath
    var targetTableView: UITableView?
    var targetCell : UITableViewCell
    var datasource: CommonFeedsDatasource
    var mediaFetcher: CFFMediaCoordinatorProtocol
    var delegate : CommonFeedsDelegate?
    weak var selectedoptionMapper : SelectedPollAnswerMapper?
    weak var themeManager: CFFThemeManagerProtocol?
    var isFeedDetailPage : Bool
    weak var networkRequestCoordinator : CFFNetworkRequestCoordinatorProtocol?
}

struct CommonFeedCellGetHeightModel {
    var targetIndexpath : IndexPath
    var datasource: CommonFeedsDatasource
}

protocol CommonFeedCellCongiguratorProtocol {
    func getCell(_ inputModel: CommonFeedCellDequeueModel) -> UITableViewCell
}
