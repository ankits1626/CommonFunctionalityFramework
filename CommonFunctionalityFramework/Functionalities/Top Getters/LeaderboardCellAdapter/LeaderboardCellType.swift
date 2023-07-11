//
//  LeaderboardCellType.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation

enum LeaderboardCellType : Int, CaseIterable{
    case Top3User = 0
    case FirstUser
    case Remaining
    
    
    static let UndIdentifiedTypeError = NSError(
        domain: "com.rewardz.LeaderboardCellTypeError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unidentified cell type."]
    )
    
    static let UndefinedConfiguratorError = NSError(
        domain: "com.rewardz.LeaderboardCellTypeError",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Unidentified configurator for cell type."]
    )
    
    func getCellConfigurator(mediaFetcher : CFFMediaCoordinatorProtocol, networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) throws -> LeaderboardCellConfiguratorProtocol {
        switch self {
        case .Top3User:
            return Top3userCellConfigurator(InitTopLeadersConfiguratorModel(mediaFetcher: mediaFetcher, networkRequestCoordinator: networkRequestCoordinator))
        case .FirstUser:
            return FirstCellConfigurator(InitTopLeadersConfiguratorModel(mediaFetcher: mediaFetcher, networkRequestCoordinator: networkRequestCoordinator))
        case .Remaining:
            return RemainingLeaderboardConfigurator(InitTopLeadersConfiguratorModel(mediaFetcher: mediaFetcher, networkRequestCoordinator: networkRequestCoordinator))
        }
        
    }
}
