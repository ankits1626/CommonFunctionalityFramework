//
//  FeedComposerCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

class FeedComposerCoordinator {
    let feedCoordinatorDeleagate: FeedsCoordinatorDelegate
     var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    init(delegate : FeedsCoordinatorDelegate, requestCoordinator: CFFNetwrokRequestCoordinatorProtocol) {
        self.feedCoordinatorDeleagate = delegate
        self.requestCoordinator = requestCoordinator
    }
    
    func showFeedItemEditor(type : FeedType) {
        let postEditor = PostEditorViewController(
            postType: type,
            requestCoordinator: requestCoordinator,
            post: nil)
        feedCoordinatorDeleagate.showComposer(_composer: postEditor) { (topBarModel) in
            postEditor.containerTopBarModel = topBarModel
        }
    }
}
