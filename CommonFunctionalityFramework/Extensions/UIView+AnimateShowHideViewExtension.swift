//
//  UIView+AnimateShowHideViewExtension.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 30/03/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

extension UIView{
    
    func animShow() {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveEaseIn],
                       animations: {
            self.center.y -= self.bounds.height
            self.layoutIfNeeded()
        }, completion: nil)
        self.isHidden = false
    }
    
    func animHide() {
        UIView.animate(withDuration: 2, delay: 0, options: [.curveLinear],
                       animations: {
            self.center.y += self.bounds.height
            self.layoutIfNeeded()
            
        },  completion: {(_ completed: Bool) -> Void in
            self.isHidden = true
        })
    }
}
