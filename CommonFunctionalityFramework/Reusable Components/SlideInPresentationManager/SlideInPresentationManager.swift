//
//  SlideInPresentationManager.swift
//  MedalCount
//
//  Created by Rewardz on 29/04/19.
//  Copyright © 2019 Ron Kliffer. All rights reserved.
//

import UIKit

enum SlideInPresentationDirection : Equatable {
  case left
  case top
  case right
  case bottom(height: CGFloat?)
}

class SlideInPresentationManager: NSObject {
  var direction = SlideInPresentationDirection.left
  
}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
  
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                               presenting: presenting,
                                                               direction: direction)
    return presentationController
  }
  
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInPresentationAnimator(direction: direction, isPresentation: true)
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return SlideInPresentationAnimator(direction: direction, isPresentation: false)
  }
  
}
