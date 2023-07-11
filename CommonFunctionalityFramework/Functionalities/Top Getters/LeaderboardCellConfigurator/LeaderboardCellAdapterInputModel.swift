//
//  LeaderboardCellAdapterInputModel.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit

struct LeaderboardCellAdapterInputModel {
    weak var delegate: LeaderboardCellAdapterDelegate!
    weak var targetTable : UITableView!
    weak var datasource: LeaderboardAdapterDatasource!
    var networkRequestCoordinator : CFFNetworkRequestCoordinatorProtocol
    var mediaFetcher : CFFMediaCoordinatorProtocol
}

