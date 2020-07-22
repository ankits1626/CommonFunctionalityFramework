//
//  CFFGifCacheManager.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

class CFFGifCacheManager : NSObject{
    private(set) var gifCache  = NSCache<NSString, NSData>()
    static let sharedInstance = CFFGifCacheManager()
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(respondToLowMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    func dropCache() {
        gifCache.removeAllObjects()
    }
    
    @objc private func respondToLowMemoryWarning(){
        gifCache.removeAllObjects()
    }
}
