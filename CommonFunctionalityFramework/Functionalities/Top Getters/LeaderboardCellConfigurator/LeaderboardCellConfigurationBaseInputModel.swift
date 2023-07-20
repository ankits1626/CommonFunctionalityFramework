//
//  LeaderboardCellConfigurationBaseInputModel.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import UIKit

class LeaderboardCellConfigurationBaseInputModel{
    weak var tableView: UITableView!
    weak var datasource : LeaderboardAdapterDatasource!
    
    init(tableView : UITableView, datasource : LeaderboardAdapterDatasource) {
        self.tableView = tableView
        self.datasource = datasource
    }
}
