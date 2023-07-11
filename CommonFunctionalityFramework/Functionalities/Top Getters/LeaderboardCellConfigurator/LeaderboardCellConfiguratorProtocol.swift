//
//  LeaderboardCellConfiguratorProtocol.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit

protocol LeaderboardCellConfiguratorProtocol {
    func registerTableviewToRespectiveCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel)
    func getCell(_ inputModel: LeaderboardConfigurationCellDequeueInputModel) -> UITableViewCell
    func configureCell(_ inputModel: LeaderboardCellConfigurationInputModel) throws
    func getHeightOfCell(_ inputModel: LeaderboardCellConfigurationBaseInputModel) -> CGFloat
}
