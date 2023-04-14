//
//  FeedsCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/03/20.
//  Copyright © 2020 Rewardz Private Limited. All rights reserved.
//

import UIKit

public protocol CFFMainAppInformationCoordinator : AnyObject {
    func isUserAllowedToPostFeed() -> Bool
    func isUserAllowedToCreatePoll() -> Bool
    func isMultiOrgPostEnabled() -> Bool
    func getCurrentUserName() -> String
    func getCurrenUserProfilePicUrl() -> String
    func getCurrentUserDepartment() -> String
    func getUserPK() -> Int
}


public struct GetFeedsViewModel{
    var networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol
    var mediaCoordinator : CFFMediaCoordinatorProtocol
    var feedCoordinatorDelegate : FeedsCoordinatorDelegate
    var themeManager : CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    var shouldShowCreateButton : Bool = false
    var isFeedLoadingFromProfilePage : Bool = false
    var searchText : String? = nil
    
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    var isGreetingType = false
    var greetingId = 0

    public init (networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol, mediaCoordinator : CFFMediaCoordinatorProtocol, feedCoordinatorDelegate : FeedsCoordinatorDelegate, themeManager : CFFThemeManagerProtocol?, mainAppCoordinator : CFFMainAppInformationCoordinator?, shouldShowCreateButton: Bool, _isFeedLoadingFromProfilePage : Bool = false, searchText : String?, _feedTypePk : Int = 0, _organisationPK : Int = 0, _departmentPK : Int = 0, _dateRangePK : Int = 0, _coreValuePk : Int = 0, _isGreetingType : Bool = false, _greetingId : Int = 0){
        self.networkRequestCoordinator = networkRequestCoordinator
        self.mediaCoordinator = mediaCoordinator
        self.feedCoordinatorDelegate = feedCoordinatorDelegate
        self.themeManager = themeManager
        self.mainAppCoordinator = mainAppCoordinator
        self.shouldShowCreateButton = shouldShowCreateButton
        self.isFeedLoadingFromProfilePage = _isFeedLoadingFromProfilePage
        self.searchText = searchText
        self.feedTypePk = _feedTypePk
        self.organisationPK = _organisationPK
        self.departmentPK = _departmentPK
        self.dateRangePK = _dateRangePK
        self.coreValuePk = _coreValuePk
        self.isGreetingType = _isGreetingType
        self.greetingId = _greetingId
    }
}

public protocol FeedsCoordinatorDelegate : AnyObject {
    func showFeedDetail(_ detailViewController : UIViewController)
    func removeFeedDetail()
    func showComposer(_composer : UIViewController, dismissCompletionBlock : (()-> Void)?, completion : @escaping ((_ topItem : EditorContainerModel) -> Void))
    func showComposer(_composer : UIViewController, completion : @escaping ((_ topItem : EditorContainerModel) -> Void))
    func showComposer(_composer : UIViewController, postType : String, completion : @escaping ((_ topItem : EditorContainerModel) -> Void))
    func showPostLikeList(_ likeListVC : UIViewController, presentationOption: GenericContainerPresentationOption, completion : @escaping ((_ topItem : GenericContainerTopBarModel) -> Void))
    func showMultiOrgPicker(_ orgPicker : UIViewController, presentationOption: GenericContainerPresentationOption, completion : @escaping ((_ topItem : GenericContainerTopBarModel) -> Void))
    
    func getVCEmbeddedInContainer(_ targetVC : UIViewController,presentationOption: GenericContainerPresentationOption, completion : @escaping ((_ topItem : GenericContainerTopBarModel) -> Void)) -> UIViewController
}

public class FeedsCoordinator {
    
    public init(){}
    
    public func getFeedsView(_ inputModel : GetFeedsViewModel) -> UIViewController{
        let feedsVc =  FeedsViewController(nibName: "FeedsViewController", bundle: Bundle(for: FeedsViewController.self))
        feedsVc.requestCoordinator = inputModel.networkRequestCoordinator
        feedsVc.mediaFetcher = inputModel.mediaCoordinator
        feedsVc.feedCoordinatorDelegate = inputModel.feedCoordinatorDelegate
        feedsVc.themeManager = inputModel.themeManager
        feedsVc.mainAppCoordinator = inputModel.mainAppCoordinator
        feedsVc.shouldShowCreateButton = inputModel.shouldShowCreateButton
        feedsVc.isComingFromProfilePage = inputModel.isFeedLoadingFromProfilePage
        feedsVc.feedTypePk = inputModel.feedTypePk
        feedsVc.organisationPK = inputModel.organisationPK
        feedsVc.departmentPK = inputModel.departmentPK
        feedsVc.dateRangePK = inputModel.dateRangePK
        feedsVc.coreValuePk = inputModel.coreValuePk
        feedsVc.searchText = inputModel.searchText
        feedsVc.isTypeGreeting = inputModel.isGreetingType
        feedsVc.greetingID = inputModel.greetingId
        if inputModel.isGreetingType {
            feedsVc.selectedTab = "GreetingsFeed"
            UserDefaults.standard.setValue("GreetingsFeed", forKey: "selectedTab")
        }else {
            feedsVc.selectedTab = ""
            UserDefaults.standard.setValue("SearchFromHome", forKey: "selectedTab")
        }
        return feedsVc
    }
    
    public func showFeedsDetailView(feedId: Int,isPostType : Bool = false, inputModel : GetFeedsViewModel,completionClosure : @escaping (_ repos :NSDictionary?) ->()){
        FeedFetcher(networkRequestCoordinator: inputModel.networkRequestCoordinator).fetchFeedDetail(feedId, feedType: "") { (result) in
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
                        feedDetailVC.mainAppCoordinator = inputModel.mainAppCoordinator
                        feedDetailVC.isPostPollType = isPostType
                        feedDetailVC.themeManager = inputModel.themeManager
                        feedDetailVC.targetFeedItem = rawFeed //feeds[indexPath.section]
                        feedDetailVC.mediaFetcher = inputModel.mediaCoordinator
                        feedDetailVC.mainAppCoordinator = inputModel.mainAppCoordinator
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
