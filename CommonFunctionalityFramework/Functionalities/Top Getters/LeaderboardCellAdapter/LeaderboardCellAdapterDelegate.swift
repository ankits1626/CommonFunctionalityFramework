//
//  LeaderboardCellAdapterDelegate.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit

protocol LeaderboardCellAdapterDelegate : class {
    func getSelectedUserIndexPath(_ sender : UIButton)
}

