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
    func selectedSharePostOption () -> SharePostOption
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
            routeToPreviewScreen(
                nil,
                displayableSelectionModel: nil,
                sharePostOption: (self.initModel.routerDelegate?.selectedSharePostOption())!
            )
        }
    }
    
    private func routeToMultiOrgPicker(){
        let orgPicker = FeedOrganisationSelectionViewController(
            FeedOrganisationSelectionInitModel(
                requestCoordinator: initModel.requestCoordinator,
                selectionModel: initModel.routerDelegate?.getSavedOrganisationAndDepartmentSelection(),
                selectionCompletionHandler: {  [weak self] selectedOrganisationsAndDeparments,displayable  in
                    self?.initModel.routerDelegate?.saveOrganisationAndDepartmentSelection(selectedOrganisationsAndDeparments)
                    self?.routeToPreviewScreen(
                        selectedOrganisationsAndDeparments,
                        displayableSelectionModel: displayable,
                        sharePostOption: (self?.initModel.routerDelegate?.selectedSharePostOption())!
                    )
                    
                })
        )
        let embeddedOrgPicker = initModel.feedCoordinatorDelegate.getVCEmbeddedInContainer(orgPicker, presentationOption: .Navigate) { topItem in
            orgPicker.containerTopBarModel = topItem
        }
        initModel.baseNavigationController?.pushViewController(embeddedOrgPicker, animated: true)
    }
    
    private func routeToPreviewScreen(_ selectedOrganisationsAndDeparments: FeedOrganisationDepartmentSelectionModel?, displayableSelectionModel : FeedOrganisationDepartmentSelectionDisplayModel?, sharePostOption: SharePostOption){
        let post = initModel.routerDelegate!.getPreviewablePost()
        let previewScreen = PostPreviewViewController(
            FeedPreviewInitModel(
                requestCoordinator: initModel.requestCoordinator,
                editorRouter: self,
                selectedOrganisationsAndDepartments: selectedOrganisationsAndDeparments,
                selectedOrganisationsAndDepartmentsDisplayable: displayableSelectionModel,
                themeManager: initModel.themeManager,
                mediaFetcher: initModel.mediaFetcher,
                post: post,
                datasource: initModel.datasource,
                localMediaManager: initModel.localMediaManager,
                postImageMapper: initModel.postImageMapper,
                delegate: initModel.delegate,
                eventListener: initModel.eventListener,
                sharePostOption: sharePostOption
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
    
    func routeToMultiOrgPickerFromPreview(){
        initModel.baseNavigationController?.popViewController(animated: true)
    }
    
    func routeToAmplifyScreen(_ amplifyInputModel: AmplifyRequestHelperProtocol, delegate: InspireMeDelegate?){
        let storyboard = UIStoryboard(
            name: "InspireMeView",
            bundle: Bundle(for: InspireMeViewController.self)
        )
        let vc = storyboard.instantiateViewController(withIdentifier: "InspireMeViewController") as! InspireMeViewController
        vc.networkRequestCoordinator = initModel.requestCoordinator
        vc.mainAppCoordinator = initModel.mainAppCoordinator
        vc.themeManager = initModel.themeManager
        vc.mediaCoordinator = initModel.mediaFetcher
        vc.inputModel = amplifyInputModel
        vc.delegate = delegate
//        vc.userText = "test"
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil
        {
            topViewController = topViewController?.presentedViewController
        }
        topViewController?.present(vc, animated: false) {
            debugPrint("<<<<<<<<<<, completed presenting inspire me")
        }
    }
    
    func routeToAmplifyErrorScreen(){
        var storyboardVcIdentifier = "AmplifyPostErrorScreen"
        var forExTextMessage : String?
        switch (initModel.datasource?.getTargetPost()?.postType)!{
        case .Poll:
            storyboardVcIdentifier = "AmplifyPollErrorScreen"
            forExTextMessage = "For example: choose your views on the new policy."
        case .Post:
            storyboardVcIdentifier = "AmplifyPostErrorScreen"
            forExTextMessage = "For example: We have a new teammate, Jacob Floyd.  Call him Jacob. He is joining us on  June19."
        case .Greeting:
            storyboardVcIdentifier = "AmplifyPostErrorScreen"
        }
        let storyboard = UIStoryboard(
            name: "InpireMeErrorView",
            bundle: Bundle(for: InpireMeErrorViewController.self))
        let vc = storyboard.instantiateViewController(withIdentifier: storyboardVcIdentifier) as! InpireMeErrorViewController
        vc.forExTextMessage = forExTextMessage
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while topViewController?.presentedViewController != nil
        {
            topViewController = topViewController?.presentedViewController
        }
        topViewController?.present(vc, animated: false, completion: nil)
    }
}


