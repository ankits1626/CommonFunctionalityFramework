//
//  CommonFeedsCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 02/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit

public struct GetCommonFeedsViewModel{
    var networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var mediaCoordinator : CFFMediaCoordinatorProtocol
    var feedCoordinatorDelegate : FeedsCommonCoordinatorDelegate
    var themeManager : CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    var selectedTabType : String
    
    public init (networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, mediaCoordinator : CFFMediaCoordinatorProtocol, feedCoordinatorDelegate : FeedsCommonCoordinatorDelegate, themeManager : CFFThemeManagerProtocol?, mainAppCoordinator : CFFMainAppInformationCoordinator?, selectedTabType : String){
        self.networkRequestCoordinator = networkRequestCoordinator
        self.mediaCoordinator = mediaCoordinator
        self.feedCoordinatorDelegate = feedCoordinatorDelegate
        self.themeManager = themeManager
        self.mainAppCoordinator = mainAppCoordinator
        self.selectedTabType = selectedTabType
    }
}


public protocol FeedsCommonCoordinatorDelegate {
    func showFeedDetail(_ detailViewController : UIViewController)
    func removeFeedDetail()
    func showComposer(_composer : UIViewController, completion : @escaping ((_ topItem : EditorContainerModel) -> Void))
    func showPostLikeList(_ likeListVC : UIViewController, presentationOption: GenericContainerPresentationOption, completion : @escaping ((_ topItem : GenericContainerTopBarModel) -> Void))
}

public class CommonFeedsCoordinator {
    
    public init(){}
    
    public func getFeedsView(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        let feedsVc =  CommonFeedsViewController(nibName: "CommonFeedsViewController", bundle: Bundle(for: CommonFeedsViewController.self))
        feedsVc.requestCoordinator = inputModel.networkRequestCoordinator
        feedsVc.mediaFetcher = inputModel.mediaCoordinator
        feedsVc.feedCoordinatorDelegate = inputModel.feedCoordinatorDelegate
        feedsVc.themeManager = inputModel.themeManager
        feedsVc.mainAppCoordinator = inputModel.mainAppCoordinator
        feedsVc.selectedTapType = inputModel.selectedTabType
        return feedsVc
    }
    
    public func getNominationView(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        let storyBoard : UIStoryboard = UIStoryboard(name: "CommonFeeds", bundle:nil)
        let nominationViewController = storyBoard.instantiateViewController(withIdentifier: "BOUSApprovalsListingViewController") as! BOUSApprovalsListingViewController
        return nominationViewController
    }
    
    public func getApprovalsView(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        
        let storyboardName = "CommonFeeds"
        let storyboardBundle =  Bundle(for: CommonFeedsViewController.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        let feedsVc = storyboard.instantiateViewController(withIdentifier: "BOUSApprovalsListingViewController") as! BOUSApprovalsListingViewController
        feedsVc.requestCoordinator = inputModel.networkRequestCoordinator
        return feedsVc

    }
    
  
    
    public func showFeedsDetailView(feedId: Int, inputModel : GetFeedsViewModel,completionClosure : @escaping (_ repos :NSDictionary?) ->()){
        FeedFetcher(networkRequestCoordinator: inputModel.networkRequestCoordinator).fetchFeedDetail(feedId, feedType: "given") { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(let result):
                    if let fetchedFeedDetail = result.fetchedRawFeeds {
                        completionClosure(["errorMessage" : ""])
                        let rawFeed = RawFeed(input: fetchedFeedDetail)
                        let _ = rawFeed.getManagedObject() as! ManagedPost
                        if let unwrappedDescription = rawFeed.getFeedDescription(){
                            FeedDescriptionMarkupParser.sharedInstance.updateDescriptionParserOutputModelForFeed(
                                feedId: rawFeed.feedIdentifier,
                                description: unwrappedDescription
                            )
                        }
                        let feedDetailVC = FeedsDetailViewController(nibName: "FeedsDetailViewController", bundle: Bundle(for: FeedsDetailViewController.self))
                        feedDetailVC.themeManager = inputModel.themeManager
                        feedDetailVC.targetFeedItem = rawFeed //feeds[indexPath.section]
                        feedDetailVC.mediaFetcher = inputModel.mediaCoordinator
                        feedDetailVC.requestCoordinator = inputModel.networkRequestCoordinator
                        feedDetailVC.feedCoordinatorDelegate = inputModel.feedCoordinatorDelegate
                        feedDetailVC.pollSelectedAnswerMapper = SelectedPollAnswerMapper()
                        inputModel.feedCoordinatorDelegate.showFeedDetail(feedDetailVC)
                    }
                case .SuccessWithNoResponseData:
                    completionClosure(["errorMessage" : "No record Found"])
                case .Failure(let error):
                    completionClosure(["errorMessage" : error.displayableErrorMessage()])
                }
            }
        }
    }
}
