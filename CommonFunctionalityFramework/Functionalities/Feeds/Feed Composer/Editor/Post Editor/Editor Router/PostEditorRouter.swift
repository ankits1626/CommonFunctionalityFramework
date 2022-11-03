//
//  PostEditorRouter.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 28/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import RewardzCommonComponents
import UIKit

struct PostEditorRouterInitModel{
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    weak var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    weak var feedCoordinatorDelegate: FeedsCoordinatorDelegate!
    weak var routerDelegate : PostEditorRouterDelegate?
    weak var baseNavigationController : UINavigationController?
    weak var themeManager: CFFThemeManagerProtocol?
    weak var mediaFetcher: CFFMediaCoordinatorProtocol!
    weak var datasource : PostEditorCellFactoryDatasource?
    weak var localMediaManager : LocalMediaManager?
    weak var postImageMapper : EditablePostMediaRepository?
    weak var delegate: PostEditorCellFactoryDelegate?
    weak var eventListener : PostPreviewViewEventListener?
}


protocol PostEditorRouterDelegate : AnyObject{
    func selectedSharePostOption () -> SharePostOption?
    func saveOrganisationAndDepartmentSelection(_ selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?)
    func getSavedOrganisationAndDepartmentSelection() -> FeedOrganisationDepartmentSelectionModel?
    func getPreviewablePost() -> PreviewablePost
    
}


class PostEditorRouter{
    private let initModel : PostEditorRouterInitModel
    init(_ initModel : PostEditorRouterInitModel){
        self.initModel = initModel
    }
    
    func routeToNextScreenFromEditor(){
        if (self.initModel.mainAppCoordinator?.isMultiOrgPostEnabled() == true) &&
            self.initModel.routerDelegate?.selectedSharePostOption() == .MultiOrg{
            routeToMultiOrgPicker()
        }else{
            routeToPreviewScreen(nil)
        }
    }
    
    private func routeToMultiOrgPicker(){
        let orgPicker = FeedOrganisationSelectionViewController(
            FeedOrganisationSelectionInitModel(
                requestCoordinator: initModel.requestCoordinator,
                selectionModel: initModel.routerDelegate?.getSavedOrganisationAndDepartmentSelection(),
                selectionCompletionHandler: {  [weak self] selectedOrganisationsAndDeparments in
                    self?.initModel.routerDelegate?.saveOrganisationAndDepartmentSelection(selectedOrganisationsAndDeparments)
                    self?.routeToPreviewScreen(selectedOrganisationsAndDeparments)
                    
                })
        )
        let embeddedOrgPicker = initModel.feedCoordinatorDelegate.getVCEmbeddedInContainer(orgPicker, presentationOption: .Navigate) { topItem in
            orgPicker.containerTopBarModel = topItem
        }
        initModel.baseNavigationController?.pushViewController(embeddedOrgPicker, animated: true)
    }
    
    private func routeToPreviewScreen(_ selectedOrganisationsAndDeparments: FeedOrganisationDepartmentSelectionModel?){
        let post = initModel.routerDelegate!.getPreviewablePost()
        let previewScreen = PostPreviewViewController(
            FeedPreviewInitModel(
                requestCoordinator: initModel.requestCoordinator,
                editorRouter: self,
                selectedOrganisationsAndDepartments: selectedOrganisationsAndDeparments,
                themeManager: initModel.themeManager,
                mediaFetcher: initModel.mediaFetcher,
                post: post,
                datasource: initModel.datasource,
                localMediaManager: initModel.localMediaManager,
                postImageMapper: initModel.postImageMapper,
                delegate: initModel.delegate,
                eventListener: initModel.eventListener
            )
        )
        let embeddedPreviewVC = initModel.feedCoordinatorDelegate.getVCEmbeddedInContainer(previewScreen, presentationOption: .Navigate) { topItem in
            previewScreen.containerTopBarModel = topItem
        }
        initModel.baseNavigationController?.pushViewController(embeddedPreviewVC, animated: true)
    }
    
    func routeToEditor(){
        initModel.baseNavigationController?.popToRootViewController(animated: true)
    }
}


