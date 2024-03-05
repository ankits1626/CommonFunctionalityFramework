//
//  LeaderboardConfigurationCellDequeueInputModel.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import UIKit

class LeaderboardConfigurationCellDequeueInputModel: LeaderboardCellConfigurationBaseInputModel {
    var indexpath: IndexPath

    init(indexpath: IndexPath, tableView : UITableView, datasource: LeaderboardAdapterDatasource) {
        self.indexpath = indexpath
        super.init(
            tableView: tableView,
            datasource: datasource
        )
    }
}
