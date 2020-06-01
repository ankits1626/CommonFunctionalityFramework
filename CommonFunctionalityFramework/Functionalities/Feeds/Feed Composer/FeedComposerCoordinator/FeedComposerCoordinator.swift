//
//  FeedComposerCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

class FeedComposerCoordinator {
    let feedCoordinatorDelegate: FeedsCoordinatorDelegate
     var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    weak var mediaFetcher : CFFMediaCoordinatorProtocol?
    private var shouldOpenGallery : Bool = false
    init(delegate : FeedsCoordinatorDelegate, requestCoordinator: CFFNetwrokRequestCoordinatorProtocol, mediaFetcher : CFFMediaCoordinatorProtocol?, shouldOpenGallery : Bool) {
        self.feedCoordinatorDelegate = delegate
        self.requestCoordinator = requestCoordinator
        self.mediaFetcher = mediaFetcher
        self.shouldOpenGallery = shouldOpenGallery
    }
    
    func showFeedItemEditor(type : FeedType) {
        openEditor(nil, type: type)
    }
    
    func editPost(feed : FeedsItemProtocol) {
        openEditor(feed, type: feed.getFeedType())
    }
    
    private func openEditor(_ feed : FeedsItemProtocol?, type : FeedType){
        let postEditor = PostEditorViewController(
            postType: type,
            requestCoordinator: requestCoordinator,
            post: feed?.getEditablePost(),
            mediaFetcher: mediaFetcher,
            shouldOpenGallery: shouldOpenGallery
        )
        feedCoordinatorDelegate.showComposer(_composer: postEditor) { (topBarModel) in
            postEditor.containerTopBarModel = topBarModel
        }
    }
}
