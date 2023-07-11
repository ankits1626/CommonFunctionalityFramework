//
//  LeaderboardAdapterDatasource.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation

protocol LeaderboardAdapterDatasource : class {
    func getNumberOfRedemptions() -> Int
    func getRedemption(index : Int) -> TopHeroesFetchedData
    func getTopHeroData() -> TopHeroesFetchedData
}
