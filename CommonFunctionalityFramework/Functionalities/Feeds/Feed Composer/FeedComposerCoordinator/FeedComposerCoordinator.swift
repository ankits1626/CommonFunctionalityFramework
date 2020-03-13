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
        showPostEditor(type)
        return
//        switch type {
//        case .Poll:
//            showPollEditor()
//        case .Post:
//            showPostEditor()
//        }
    }
    private func showPostEditor(_ type : FeedType) {
        let postEditor = PostEditorViewController(nibName: "PostEditorViewController", bundle: Bundle(for: PostEditorViewController.self))
        postEditor.postType = type
        postEditor.requestCoordinator = requestCoordinator
        feedCoordinatorDeleagate.showComposer(_composer: postEditor) { (topBarModel) in
            postEditor.containerTopBarModel = topBarModel
        }
    }
    
    private func showPollEditor(){
        let pollEditor = PollEditorViewController(nibName: "PollEditorViewController", bundle: Bundle(for: PollEditorViewController.self))
        feedCoordinatorDeleagate.showComposer(_composer: pollEditor) { (topBarModel) in
            pollEditor.containerTopBarModel = topBarModel
        }
    }
}
