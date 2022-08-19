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
     var requestCoordinator: CFFNetworkRequestCoordinatorProtocol
    weak var mediaFetcher : CFFMediaCoordinatorProtocol?
    private var selectedAssets : [LocalSelectedMediaItem]?
    weak var themeManager: CFFThemeManagerProtocol?
    var selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?
    private weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    
    init(delegate : FeedsCoordinatorDelegate, requestCoordinator: CFFNetworkRequestCoordinatorProtocol, mediaFetcher : CFFMediaCoordinatorProtocol?, selectedAssets : [LocalSelectedMediaItem]?, themeManager: CFFThemeManagerProtocol?, selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?,
         mainAppCoordinator : CFFMainAppInformationCoordinator?) {
        self.feedCoordinatorDelegate = delegate
        self.requestCoordinator = requestCoordinator
        self.mediaFetcher = mediaFetcher
        self.selectedAssets = selectedAssets
        self.themeManager = themeManager
        self.selectedOrganisationsAndDepartments = selectedOrganisationsAndDepartments
        self.mainAppCoordinator = mainAppCoordinator
    }
    
    func showFeedItemEditor(type : FeedType) {
        openEditor(nil, type: type)
    }
    
    func editPost(feed : FeedsItemProtocol) {
        openEditor(feed, type: feed.getFeedType())
    }
    
    private func openEditor(_ feed : FeedsItemProtocol?, type : FeedType){
        let editabalePost = feed?.getEditablePost()
        let postEditor = PostEditorViewController(
            postType: type,
            requestCoordinator: requestCoordinator,
            post: editabalePost,
            mediaFetcher: mediaFetcher,
            selectedAssets: selectedAssets,
            themeManager : themeManager,
            selectedOrganisationsAndDepartments: editabalePost?.selectedOrganisationsAndDepartments,
            mainAppCoordinator: mainAppCoordinator,
            feedCoordinatorDelegate: feedCoordinatorDelegate
        )
        let feedTitle = type == .Poll ? "Poll" : "Post"
        feedCoordinatorDelegate.showComposer(_composer: postEditor, postType: feedTitle) { topItem in
            postEditor.containerTopBarModel = topItem
        }
    }
}
