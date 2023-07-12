//
//  LeaderboardAdapterDatasource.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation

protocol LeaderboardAdapterDatasource : class {
    func getNumberOfTopGetters() -> Int
    func getTopHeroData() -> TopHeroesFetchedData
    func getTopGetters(index: Int) -> TopHeroesFetchedData
}
