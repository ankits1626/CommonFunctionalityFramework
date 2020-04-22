//
//  Array+Extension.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 22/04/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}
