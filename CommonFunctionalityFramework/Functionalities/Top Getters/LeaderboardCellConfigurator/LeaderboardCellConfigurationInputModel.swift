//
//  LeaderboardCellConfigurationInputModel.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import UIKit

class LeaderboardCellConfigurationInputModel: LeaderboardConfigurationCellDequeueInputModel {
    weak var cell: UITableViewCell!
    weak var eventListener: LeaderboardCellAdapterDelegate!
    
    init(cell: UITableViewCell,eventListener: LeaderboardCellAdapterDelegate, tableView : UITableView, datasource : LeaderboardAdapterDatasource, indexpath : IndexPath) {
        self.cell = cell
        self.eventListener = eventListener
        super.init(
            indexpath: indexpath,
            tableView: tableView,
            datasource: datasource
        )
    }
}
