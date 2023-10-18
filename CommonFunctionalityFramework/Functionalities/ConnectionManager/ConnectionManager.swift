//
//  ConnectionManager.swift
//  SKOR
//
//  Created by Suyesh Kandpal on 25/09/23.
//  Copyright © 2023 Rewradz Private Limited. All rights reserved.
//

import Foundation
import Reachability

public class ConnectionManager {

    public static let shared = ConnectionManager()
    public init () {}

    public func hasConnectivity() -> Bool {
        do {
            let reachability: Reachability = try Reachability() ?? Reachability()!
            let networkStatus = reachability.connection
            
            switch networkStatus {
            case .none:
                return false
            case .wifi, .cellular:
                return true
            }
        }
        catch {
            return false
        }
    }
}
