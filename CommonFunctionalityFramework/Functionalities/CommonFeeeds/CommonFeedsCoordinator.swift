//
//  CommonFeedsCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 02/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit
import RewardzCommonComponents

public struct GetCommonFeedsViewModel{
    var networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var mediaCoordinator : CFFMediaCoordinatorProtocol
    var feedCoordinatorDelegate : FeedsCommonCoordinatorDelegate
    var themeManager : CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    var selectedTabType : String
    var searchText : String?
    
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    
    public init (networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, mediaCoordinator : CFFMediaCoordinatorProtocol, feedCoordinatorDelegate : FeedsCommonCoordinatorDelegate, themeManager : CFFThemeManagerProtocol?, mainAppCoordinator : CFFMainAppInformationCoordinator?, selectedTabType : String, searchText : String?, _feedTypePk : Int, _organisationPK : Int, _departmentPK : Int, _dateRangePK : Int, _coreValuePk : Int){
        self.networkRequestCoordinator = networkRequestCoordinator
        self.mediaCoordinator = mediaCoordinator
        self.feedCoordinatorDelegate = feedCoordinatorDelegate
        self.themeManager = themeManager
        self.mainAppCoordinator = mainAppCoordinator
        self.selectedTabType = selectedTabType
        self.searchText = searchText
        self.feedTypePk = _feedTypePk
        self.organisationPK = _organisationPK
        self.departmentPK = _departmentPK
        self.dateRangePK = _dateRangePK
        self.coreValuePk = _coreValuePk
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
    var loader = MFLoader()
    
    public func getFeedsView(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        let feedsVc =  CommonFeedsViewController(nibName: "CommonFeedsViewController", bundle: Bundle(for: CommonFeedsViewController.self))
        feedsVc.requestCoordinator = inputModel.networkRequestCoordinator
        feedsVc.mediaFetcher = inputModel.mediaCoordinator
        feedsVc.feedCoordinatorDelegate = inputModel.feedCoordinatorDelegate
        feedsVc.themeManager = inputModel.themeManager
        feedsVc.mainAppCoordinator = inputModel.mainAppCoordinator
        feedsVc.selectedTabType = inputModel.selectedTabType
        feedsVc.searchText = inputModel.searchText
        feedsVc.feedTypePk = inputModel.feedTypePk
        feedsVc.organisationPK = inputModel.organisationPK
        feedsVc.departmentPK = inputModel.departmentPK
        feedsVc.dateRangePK = inputModel.dateRangePK
        feedsVc.coreValuePk = inputModel.coreValuePk
        return feedsVc
    }
    
    public func getNominationView(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        let storyBoard : UIStoryboard = UIStoryboard(name: "CommonFeeds", bundle:nil)
        let nominationViewController = storyBoard.instantiateViewController(withIdentifier: "BOUSApprovalsListingViewController") as! BOUSApprovalsListingViewController
        return nominationViewController
    }
    
    public func getApprovalsView(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        
        let storyboardName = "CommonFeeds"
        let storyboardBundle =  Bundle(for: BOUSNominationViewController.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        let feedsVc = storyboard.instantiateViewController(withIdentifier: "BOUSNominationViewController") as! BOUSNominationViewController
        feedsVc.requestCoordinator = inputModel.networkRequestCoordinator
        feedsVc.statusType = inputModel.selectedTabType
        feedsVc.mediaFetcher = inputModel.mediaCoordinator
        return feedsVc

    }
    
    public func getApprovalsViewFromFeeds(_ inputModel : GetCommonFeedsViewModel) -> UIViewController{
        let storyboardName = "CommonFeeds"
        let storyboardBundle =  Bundle(for: BOUSApprovalsListingViewController.self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        let feedsVc = storyboard.instantiateViewController(withIdentifier: "BOUSApprovalsListingViewController") as! BOUSApprovalsListingViewController
        feedsVc.requestCoordinator = inputModel.networkRequestCoordinator
        feedsVc.mediaFetcher = inputModel.mediaCoordinator
        feedsVc.searchText = inputModel.searchText
        return feedsVc

    }

    public func showFeedsDetailView(feedId: Int, inputModel : GetFeedsViewModel,completionClosure : @escaping (_ repos :NSDictionary?) ->()){
        self.loader.showActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
        FeedFetcher(networkRequestCoordinator: inputModel.networkRequestCoordinator).fetchFeedDetail(feedId, feedType: "given") { (result) in
            DispatchQueue.main.async {
                self.loader.hideActivityIndicator(UIApplication.shared.keyWindow?.rootViewController?.view ?? UIView())
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
