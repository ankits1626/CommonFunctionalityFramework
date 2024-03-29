//
//  FeedsDetailViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 05/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift

enum FeedDetailSection : Int {
    case FeedInfo = 0
    case ClapsSection
    case Comments
}

enum DisplayFeedOptions {
    case Appreciation
    case POSTPOLL
}

protocol FeedsDetailCommentsProviderProtocol{
    func getNumberOfComments() -> Int
    func getComment(_ index : Int) -> FeedComment?
}
class FeedsDetailViewController: UIViewController, PostEditorCellFactoryDelegate {


    var feedFetcher: CFFNetworkRequestCoordinatorProtocol!
    private var tagPicker : ASMentionSelectorViewController?
    @IBOutlet weak var commentBarView : ASChatBarview?
    @IBOutlet weak var feedDetailTableView : UITableView?
    var targetFeedItem : FeedsItemProtocol!
    var clappedByUsers : [ClappedByUser]?
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    weak var themeManager: CFFThemeManagerProtocol?
    var feedCoordinatorDelegate: FeedsCoordinatorDelegate!
    weak var mainAppCoordinator : CFFMainAppInformationCoordinator?
    var selectedTab = ""
    @IBOutlet weak var downloadCompletedView: UIView!
    var isPostPollType : Bool = false
    var is_download_choice_needed : Bool = false
    var can_download : Bool = false
    var showDisplayOptions : DisplayFeedOptions?
    var isDesklessEnabled : Bool = false

    lazy var feedDetailSectionFactory: FeedDetailSectionFactory = {
        return FeedDetailSectionFactory(
            self,
            feedDetailDelegate: self,
            mediaFetcher: mediaFetcher,
            targetTableView: feedDetailTableView,
            themeManager: themeManager,
            selectedOptionMapper: pollSelectedAnswerMapper,
            selectedTab: selectedTab,
            _isPostPoll: isPostPollType,
            mainAppCoordinator: mainAppCoordinator,
            canDownload: can_download,
            isDesklessEnabled: isDesklessEnabled
        )
    }()
    var pollSelectedAnswerMapper: SelectedPollAnswerMapper?
    private var frc : NSFetchedResultsController<ManagedPostComment>?
    private var lastFetchedComments : FeedCommentsFetchResult?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    private func setup(){
        view.backgroundColor = .white
        setupTableView()
        setupCommentBar()
        fetchClappedByUsers()
        observeChangesToPost()
    }
    
    private func observeChangesToPost(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadPost),
            name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
            object: CFFCoreDataManager.sharedInstance.manager.mainQueueContext)
    }
    
    private func setupCommentBar(){
        commentBarView?.backgroundColor = .commentBarBackgroundColor
//        commentBarView?.placeholder = "Enter your comments here".localized
//        commentBarView?.placeholderColor = .getPlaceholderTextColor()
//        commentBarView?.placeholderFont = .Body1
        commentBarView?.themeManager = themeManager
        commentBarView?.requestCoordinator = requestCoordinator
        commentBarView?.mediaFetcher = mediaFetcher
        commentBarView?.setupUserProfile()
        commentBarView?.backgroundColor = .white
        commentBarView?.sendBtnView.backgroundColor = UIColor.getControlColor()
//        commentBarView?.leftUserImg.image = UIImage(named: "")
    }
    
    
    func updateProfilePic()  {
        let pic = ""
           if !pic.isEmpty {
//               commentBarView?.leftUserImg?.sd_setImage(
//                   with: URL(string: getServiceURL() + getProfilePic()),
//                  placeholderImage: nil,
//                  completed: nil
//              )
           }else{
              // commentBarView?.leftUserImg?.setImageForName(getfullName(), circular: false, textAttributes: nil)
           }
       }
 
    private func setupTableView(){
        feedDetailTableView?.tableFooterView = UIView(frame: CGRect.zero)
        feedDetailTableView?.rowHeight = UITableView.automaticDimension
        feedDetailTableView?.estimatedRowHeight = 140
        feedDetailTableView?.dataSource = self
        feedDetailTableView?.delegate = self
        feedDetailTableView?.reloadData()
        feedDetailTableView?.loadCFFControl = CFFLoadControl(target: self, action: #selector(fetchComments))
        feedDetailTableView?.loadCFFControl?.heightLimit = 100.0
    }
    
    private func initializeFRC() {
        let fetchRequest: NSFetchRequest<ManagedPostComment> = ManagedPostComment.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "commentId", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: CFFCoreDataManager.sharedInstance.manager.mainQueueContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc?.delegate = self
        do {
            try frc?.performFetch()
            feedDetailTableView?.reloadData()
        } catch let error {
            print("<<<<<<<<<< error \(error.localizedDescription)")
        }
    }
    
    private func clearAnyExistingFeedsData(_ completion: @escaping (() -> Void)){
        CFFCoreDataManager.sharedInstance.manager.deleteAllObjetcs(type: ManagedPostComment.self) {
            DispatchQueue.main.async {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                completion()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearAnyExistingFeedsData {[weak self] in
            ASMentionCoordinator.shared.delegate = self
            self?.initializeFRC()
            self?.fetchFeedDetail()
            self?.setup()
            self?.fetchComments()
            ASChatBarview().setNeedsDisplay()
            ASChatBarview().layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addTagPicker()
    }
    
    private func addTagPicker(){
        if tagPicker == nil{
            tagPicker = ASMentionSelectorViewController(nibName: "ASMentionSelectorViewController", bundle: Bundle(for: ASMentionSelectorViewController.self))
            tagPicker?.networkRequestCoordinator = requestCoordinator
        }
        tagPicker?.mediaFetcher = mediaFetcher
    }
    
    func showUserListForTagging(searckKey : String, textView: UITextView, pickerDelegate : TagUserPickerDelegate?){
        tagPicker?.pickerDelegate = pickerDelegate
        if
            let confirmedTextViewCursorPosition = textView.selectedTextRange?.end {
            let caretPosition = textView.caretRect(for: confirmedTextViewCursorPosition)
            let textViewActualPosition = textView.convert(caretPosition, to: view)
            tagPicker?.searchForUser(
                searckKey,
                displayRect: textViewActualPosition,
                parent: self,
                shouldSearchOnlyDepartment: false
            )
        }
    }
    
    func updateTagPickerFrame(_ textView: UITextView?) {
        if
            let confirmedTextViewCursorPosition = textView?.selectedTextRange?.end,
            let caretPosition = textView?.caretRect(for: confirmedTextViewCursorPosition),
            let textViewActualPosition = textView?.convert(caretPosition, to: view){
            tagPicker?.updateFrameOfPicker(textViewActualPosition)
        }
    }
    
    func dismissUserListForTagging(completion :(() -> Void)){
        tagPicker?.dismissTagSelector(completion)
    }
    
    @objc private func fetchComments(){
        FeedCommentsFetcher(networkRequestCoordinator: requestCoordinator).fetchComments(
        feedId: targetFeedItem.feedIdentifier, nextpageUrl: lastFetchedComments?.nextPageUrl) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(let result):
                    DispatchQueue.main.async {[weak self] in
                        self?.lastFetchedComments = result
                        self?.feedDetailTableView?.loadCFFControl?.endLoading()
                    }
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        if let comments = result.fetchedComments{
                            comments.forEach { (aRawComment) in
                                let _ = aRawComment.getManagedObject() as! ManagedPostComment
                            }
                            CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                            }
                        }
                    }
                    
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(let _):
                    print("unable to fetch comments")
                }
            }
        }
    }
    
    private func fetchClappedByUsers(){
        PostLikeListFetcher(networkRequestCoordinator: requestCoordinator).fetchLikeList(
        feedIdentifier: targetFeedItem.feedIdentifier, nextPageUrl: nil) { (result) in
            switch result{
            case .Success(result: let result):
                var likeList = [ClappedByUser]()
                if let results = result.fetchedLikes?["results"] as? [[String : Any]]{
                    results.forEach { (aRawLike) in
                        if let userInfo = aRawLike["user_info"] as? [String : Any]{
                            likeList.append(ClappedByUser(userInfo, reactionType: aRawLike["reaction_type"] as! Int ))
                        }
                    }
                }
                
                DispatchQueue.main.async {[weak self] in
                    self?.clappedByUsers = likeList
                    self?.feedDetailTableView?.reloadData()
                }
            case .SuccessWithNoResponseData:
                fallthrough
            case .Failure(error: _):
                print("<<<<<<< error while fetching like list")
            }
        }
    }
    
    private func fetchFeedDetail() {
        FeedDetailsFetcherFormWorker(networkRequestCoordinator: requestCoordinator).getFeedDetailsFetcher(feedId: targetFeedItem.feedIdentifier) { (result) in
            switch result{
            case .Success(result: let result):
                self.can_download = result["can_download"] as? Bool ?? false
                self.is_download_choice_needed = result["is_download_choice_needed"] as? Bool ?? false
                DispatchQueue.main.async {
                    self.feedDetailSectionFactory.reloadDownloadCertificateButton(canDownload: self.can_download)
                    self.feedDetailTableView?.reloadData()
                }
            case .SuccessWithNoResponseData:
                fallthrough
            case .Failure(error: _):
                print("<<<<<<< error while fetching like list")
            }
        }
    }
    
    func numberOfRowsIncrement(number: Int) {
        
    }
    
    @objc private func reloadPost(notification: NSNotification){
        guard let userInfo = notification.userInfo else { return }
        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<ManagedPost>,
            let updatedPost = updates.first?.getRawObject() as? FeedsItemProtocol{
             print("<<<<<<<<<<< reloadPost")
            targetFeedItem = updatedPost
            feedDetailTableView?.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }
    
    func reloadTextViewContainingRow(indexpath: IndexPath) {
    }
    
    func createdPostType(_ isEnabled: Bool?) {
        
    }
    
    func openPhotoLibrary() {
        
    }
    
    func openGif() {
        
    }
    
    func openECard() {
        
    }
    
    func updatePostTitle(title: String?) {
    }
    
    func updatePostDescription(decription: String?) {
    }
    
    func removeSelectedMedia(index: Int, mediaSection: EditableMediaSection) {
    }
    
    func removeAttachedGif() {
    }
    
    func savePostOption(index: Int, option: String?) {
    }
    
    func activeDaysForPollChanged(_ days: Int) {
    }
    
    func removeAttachedECard() {
    }
    
    func triggerAmplify() {
    }
}

extension FeedsDetailViewController : FeedsDetailCommentsProviderProtocol{
    func getNumberOfComments() -> Int {
        guard let sections = frc?.sections else {
            return 0
        }
        let sectionInfo = sections[0]
        return sectionInfo.numberOfObjects
    }
    
    func getComment(_ index: Int) -> FeedComment? {
        return frc?.object(at: IndexPath(item: index, section: 0)).getRawObject() as? FeedComment
    }
    
    
}

extension FeedsDetailViewController : FeedsDatasource{
    func getPostShareOption() -> SharePostOption {
        return .MyOrg //dummy will be changes if we plan to show selected org/department on feed detail
    }
    
    func getPostSharedWithOrgAndDepartment() -> FeedOrganisationDepartmentSelectionDisplayModel? {
        return nil
    }
    
    func shouldShowMenuOptionForFeed() -> Bool {
        return mainAppCoordinator?.isUserAllowedToPostFeed() ?? true
    }
    
    func getCommentProvider() -> FeedsDetailCommentsProviderProtocol? {
        return self
    }
    
    func getTargetPost() -> EditablePostProtocol? {
        return nil
    }
    
    func showShowFullfeedDescription() -> Bool {
        return true
    }
    
    func getNumberOfItems() -> Int {
        return 0
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return targetFeedItem
    }
    
    func getClappedByUsers() -> [ClappedByUser]? {
        return clappedByUsers
    }
    
    func getFeedItem() -> FeedsItemProtocol!{
        return targetFeedItem
    }
}

extension FeedsDetailViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedDetailSectionFactory.getNumberOfSectionsForFeedDetailView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedDetailSectionFactory.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  feedDetailSectionFactory.getCell(indexPath: indexPath, tableView: tableView)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        feedDetailSectionFactory.configureCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return feedDetailSectionFactory.getHeightOfCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return feedDetailSectionFactory.getViewForHeaderInSection(section: section, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return feedDetailSectionFactory.getHeightOfViewForSection(section: section)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadCFFControl?.update()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollView.loadCFFControl?.update()
    }
}

extension FeedsDetailViewController : FeedsDelegate, CompletedCertificatedDownload{
    func showTeamInfo() {
        let groupVc = GroupBottomSheet(nibName: "GroupBottomSheet", bundle: Bundle(for: GroupBottomSheet.self))
        if let unwrapedData = targetFeedItem.getCategoryName() {
            groupVc.categoryName = unwrapedData.name
            groupVc.categoryImage = unwrapedData.image
        }
        groupVc.modalPresentationStyle = .overCurrentContext
        self.present(groupVc, animated: true)
    }
    
    func showUserProfileView(targetView: UIView?, feedIdentifier: Int64) {
        print("here")
    }
    
 
    func editComment(commentIdentifier: Int64, chatMessage: String, commentedByPk: Int) {
        print(commentedByPk)
        var numberofElementsEnabled : CGFloat = 0.0
        let drawer = EditCommentDrawer(nibName: "EditCommentDrawer", bundle: Bundle(for: EditCommentDrawer.self))
        drawer.bottomsheetdelegate = self
        drawer.commentFeedIdentifier = commentIdentifier
        drawer.chatMessage = chatMessage
        if mainAppCoordinator?.getUserPK() == commentedByPk || targetFeedItem.isFeedEditAllowed() {
            drawer.isEditEnabled = true
            numberofElementsEnabled = numberofElementsEnabled + 1
        }else{
            drawer.isEditEnabled = false
        }
        
        if mainAppCoordinator?.getUserPK() == commentedByPk || targetFeedItem.isFeedDeleteAllowed(){
            numberofElementsEnabled = numberofElementsEnabled + 1
            drawer.isDeleteEnabled = true
        }else{
            drawer.isDeleteEnabled = false
        }
        do{
            try drawer.presentDrawer(numberofElementsEnabled: numberofElementsEnabled)
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
    }
    
    func deleteComment(commentIdentifier : Int64) {
        CommentDeleteWorker(networkRequestCoordinator: self.requestCoordinator).deleteComment(commentIdentifier) { (result) in
            switch result{
            case .Success(result: _):
                DispatchQueue.main.async {[weak self] in
                    if let feedItem = self?.targetFeedItem{
                        CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                            if let comment = self?.getLikeableComment(commentIdentifier: commentIdentifier){
                                let commentonPost = comment.getManagedObject() as! ManagedPostComment
                                let post = ((feedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                                post.numberOfComments =  post.numberOfComments - 1
                                self?.targetFeedItem = post.getRawObject() as! RawFeed
                                CFFCoreDataManager.sharedInstance.manager.deleteManagedObject(managedObject: commentonPost, context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext)
                                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                    print("<<<<<<<<<<<<<poll deleted suceessfully")
                                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                    DispatchQueue.main.async {
                                        ErrorDisplayer.showError(errorMsg: "Deleted successfully.".localized) { (_) in
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            case .SuccessWithNoResponseData:
                fallthrough
            case .Failure(error: _):
                print("<<<<< Unable to delete post")
            }
        }
    }
    
    
    func showPostReactions(feedIdentifier: Int64) {
        
    }
    
    func toggleLikeForComment(commentIdentifier: Int64) {
        if let comment = getLikeableComment(commentIdentifier: commentIdentifier){
            print("<<<<<<<<< toggle like \(commentIdentifier)")
            FeedClapToggler(networkRequestCoordinator: requestCoordinator).toggleLike(comment) { (result) in
                switch result{
                case .Success(result: let result):
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        let comment = comment.getManagedObject() as! ManagedPostComment
                        comment.isLikedByMe = result.isLiked
                        comment.numberOfLikes = result.totalLikeCount
                    
                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                        }
                    }
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(error: let _):
                    print("<<<<<<<<<< like/unlike call completed \(result)")
                }
            }
        }
    }
    
    func postReaction(feedId: Int64, reactionType: String){
            if let reactionId = reactionType as? String{
                BOUSReactionPostWorker(networkRequestCoordinator: requestCoordinator).postReaction(postId: Int(feedId), reactionType: Int(reactionId)!){ [weak self] (result) in
                    DispatchQueue.main.async {
                        switch result{
                        case .Success(result: let result):

                            CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                                let post = ((self?.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                                                            if let likesResult =  result as? NSDictionary {
                                                                post.numberOfLikes = likesResult["count"] as? Int64 ?? 0
                                                                if let dataVal = likesResult["post_reactions"] as? NSArray {
                                                                    post.reactionTypesData =  dataVal
                                                                    post.messageType = Int64(likesResult.object(forKey: "reaction_type") as? Int ?? -1)
                                                                }
                                                            }
                                                            CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                                                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                                            }
                                                        }
                            
                            break
                        case .SuccessWithNoResponseData:
                            fallthrough
                        case .Failure(_):
                            ErrorDisplayer.showError(errorMsg: "Failed to post, please try again.".localized) { (_) in}
                        }
                    }
                }
                
            }
        
    }
    
    func pinToPost(feedIdentifier : Int64, isAlreadyPinned: Bool) {
        print("<<<<<<Feed identifier-\(feedIdentifier)")
        showPintoPostConfirmation(feedIdentifier, isAlreadyPinned: isAlreadyPinned)
    }
    
    private func showPintoPostConfirmation(_ feedIdentifier : Int64, isAlreadyPinned: Bool){
            let pinPostDrawer = PintoTopConfirmationDrawer(
                nibName: "PintoTopConfirmationDrawer",
                bundle: Bundle(for: PintoTopConfirmationDrawer.self)
            )
            pinPostDrawer.themeManager = themeManager
        pinPostDrawer.isAlreadyPinned = isAlreadyPinned
            pinPostDrawer.targetFeed = targetFeedItem
            pinPostDrawer.confirmedCompletion = {postFrequency in
                PostPinWorker(networkRequestCoordinator: self.requestCoordinator).postPin(feedIdentifier, frequency: postFrequency) { (result) in
                    DispatchQueue.main.async {
                        switch result{
                        case .Success(_):
                            ErrorDisplayer.showError(errorMsg: isAlreadyPinned ? "\(pinPostDrawer.targetFeed?.getFeedType() == .Post ? "Post" : "Poll") is unpinned successfully".localized : "\(pinPostDrawer.targetFeed?.getFeedType() == .Post ? "Post" : "Poll") is pinned successfully".localized, okActionHandler: { (_) in
                                NotificationCenter.default.post(name: .didUpdatedPosts, object: nil)
                                self.navigationController?.popViewController(animated: true)
                            })
                        case .SuccessWithNoResponseData:
                            fallthrough
                        case .Failure(_):
                            ErrorDisplayer.showError(errorMsg: "Failed to pin poll, please try again.".localized) { (_) in}
                        }
                    }
                }
            }
            do{
                try pinPostDrawer.presentDrawer()
            }catch {
                
            }
        }
    
    func showPostReactions() {
        let storyboard = UIStoryboard(name: "CommonFeeds",bundle: Bundle(for: CommonFeedsViewController.self))
        let controller = storyboard.instantiateViewController(withIdentifier: "BOUSReactionsListViewController") as! BOUSReactionsListViewController
        controller.postId = Int(targetFeedItem.feedIdentifier)
        controller.requestCoordinator = requestCoordinator
        controller.mediaFetcher = mediaFetcher
        self.tabBarController?.tabBar.isHidden = true
        NotificationCenter.default.post(name: Notification.Name(rawValue: "hideMenuButton"), object: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func getLikeableComment(commentIdentifier: Int64) -> FeedComment?{
        let fetchRequest = NSFetchRequest<ManagedPostComment>(entityName: "ManagedPostComment")
        fetchRequest.predicate = NSPredicate (format: "commentId == %d", commentIdentifier)
        do{
            let filterdComments = try CFFCoreDataManager.sharedInstance.manager.mainQueueContext.fetch(fetchRequest)
            return filterdComments.first?.getRawObject() as? FeedComment
        }catch{
            return nil
        }
    }
    
    func showAllClaps(feedIdentifier: Int64) {}
    
    func submitPollAnswer(feedIdentifier: Int64) {
        print("from detail page post answer")
        if let selectedOption = pollSelectedAnswerMapper?.getSelectedOption(feedIdentifier: feedIdentifier){
            PollAnswerSubmitter(networkRequestCoordinator: requestCoordinator, feedIdentifier: feedIdentifier, answer: selectedOption).submitAnswer { (result) in
                switch result{
                case .Success(result: let result):
                    print("<<<<<<<< update raw poll after answer submission")
                    DispatchQueue.main.async {[weak self] in
                        self?.pollSelectedAnswerMapper?.removeSelectedOptionAfterAnswerIsPosted(feedIdentifier: feedIdentifier)
                    }
                    CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                        let _ = result.getManagedObject() as! ManagedPost
                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                        }
                    }
                    
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(error: _):
                    print("<<<<<<<<<< like/unlike call completed \(result)")
                }
                
            }
        }else{
            ErrorDisplayer.showError(errorMsg: "Please select an option.") { (_) in
                
            }
        }
    }
    
    func selectPollAnswer(feedIdentifier: Int64, pollOption: PollOption) {
        print("select answer for feed \(feedIdentifier), answer : \(pollOption.getNewtowrkPostableAnswer())")
        pollSelectedAnswerMapper?.toggleOptionSelection(pollId: feedIdentifier, selectedOption: pollOption)
        CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
            let post = ((self.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost)
            post?.pollUpdatedTrigger = NSDate()
            CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
            }
        }
    }
    
    func toggleClapForPost(feedIdentifier: Int64) {
        FeedClapToggler(networkRequestCoordinator: requestCoordinator).toggleLike(targetFeedItem) { [weak self](result) in
            switch result{
            case .Success(result: let result):
                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                    let post = ((self?.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                    post.isLikedByMe = result.isLiked
                    post.numberOfLikes = result.totalLikeCount
                    self?.targetFeedItem = post.getRawObject() as! RawFeed
                    CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                        CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                        DispatchQueue.main.async {
                            self?.feedDetailSectionFactory.reloadToShowLikeAndCommentCountUpdate()
                            self?.fetchClappedByUsers()
                        }
                    }
                }
            case .SuccessWithNoResponseData:
                fallthrough
            case .Failure(error: let _):
                print("<<<<<<<<<< like/unlike call completed \(result)")
            }
            
        }
    }
    
    func showMediaBrowser(feedIdentifier: Int64, scrollToItemIndex: Int) {
        if let feed =  targetFeedItem,
            let mediaItems = feed.getMediaList(){
            let mediaBrowser = CFFMediaBrowserViewController(
                mediaList: mediaItems,
                mediaFetcher: mediaFetcher,
                selectedIndex: scrollToItemIndex
            )
            present(mediaBrowser, animated: true, completion: nil)
        }
    }
    
    func showFeedEditOptions(targetView: UIView?, feedIdentifier: Int64) {
        //need to discuss
        if isDesklessEnabled {
            if isPostPollType {
                if targetFeedItem.isFeedReportAbuseAllowed(){
                    self.showReportAbuseConfirmation(feedIdentifier)
               }
            }else {
                if targetFeedItem.getPostType() == .Appreciation {
                    let downloadFeedCertificateViewController = DownloadFeedCertificateViewController(nibName: "DownloadFeedCertificateViewController", bundle: Bundle(for: DownloadFeedCertificateViewController.self))
                    downloadFeedCertificateViewController.targetFeed = targetFeedItem
                    downloadFeedCertificateViewController.mediaFetcher = mediaFetcher
                    downloadFeedCertificateViewController.themeManager = themeManager
                    downloadFeedCertificateViewController.is_download_choice_needed = is_download_choice_needed
                    downloadFeedCertificateViewController.requestCoordinator = requestCoordinator
                    downloadFeedCertificateViewController.delegate = self
                    do{
                        try downloadFeedCertificateViewController.presentDrawer()
                    }catch {
                        
                    }
                }else {
                    if targetFeedItem.isFeedReportAbuseAllowed(){
                        self.showReportAbuseConfirmation(feedIdentifier)
                    }
                }
            }
        }else {
            if self.showDisplayOptions == .POSTPOLL {
                var numberofElementsEnabled : CGFloat = 0.0
                let drawer = PostPollSelfBottomSheet(nibName: "PostPollSelfBottomSheet", bundle: Bundle(for: PostPollSelfBottomSheet.self))
                drawer.bottomsheetdelegate = self
                drawer.feedIdentifier = feedIdentifier
                drawer.isPostAlreadyPinned = targetFeedItem.isPinToPost()
                if targetFeedItem.isFeedEditAllowed() && targetFeedItem.getFeedType() == .Post {
                    drawer.isEditEnabled = true
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }else{
                    drawer.isEditEnabled = false
                }
                
                if targetFeedItem.isLoggedUserAdmin()  == true{
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }
                
                if targetFeedItem.isFeedDeleteAllowed() == true{
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }
                if targetFeedItem.isFeedReportAbuseAllowed() == true{
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }
                drawer.isPintoPostEnabled = targetFeedItem.isLoggedUserAdmin()
                drawer.isDeleteEnabled = targetFeedItem.isFeedDeleteAllowed()
                drawer.isreportAbusedEnabled = targetFeedItem.isFeedReportAbuseAllowed()
                do{
                    try drawer.presentDrawer(numberofElementsEnabled: numberofElementsEnabled)
                }catch let error{
                    print("show error")
                    ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
                    }
                }
            }else {
                var numberofElementsEnabled : CGFloat = 0.0
                let drawer = AppreciationBottomSheet(nibName: "AppreciationBottomSheet", bundle: Bundle(for: AppreciationBottomSheet.self))
                drawer.bottomsheetdelegate = self
                drawer.feedIdentifier = feedIdentifier

                if targetFeedItem.isLoggedUserAdmin()  == true{
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }

                if targetFeedItem.isFeedDeleteAllowed() == true{
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }
                if targetFeedItem.isFeedReportAbuseAllowed() == true{
                    numberofElementsEnabled = numberofElementsEnabled + 1
                }

                drawer.isDeleteFlagEnabled = targetFeedItem.isFeedDeleteAllowed()
                drawer.isreportAbusedEnabled = targetFeedItem.isFeedReportAbuseAllowed()
                drawer.isAdminUser = targetFeedItem.isLoggedUserAdmin()
                do{
                    try drawer.presentDrawer(numberofElementsEnabled: numberofElementsEnabled)
                }catch let error{
                    print("show error")
                    ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
                    }
                }
            }
        }
    }
    
    func didFinishSavingCertificate(didSave: Bool) {
        if didSave {
            didFinishSavingCertificate()
        }
        is_download_choice_needed = false
    }
    
    func didFinishSavingCertificate() {
          downloadCompletedView.animShow()
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              self.downloadCompletedView.animHide()
          }
      }
    
    private func openFeedEditor(_ feed : FeedsItemProtocol){
        FeedComposerCoordinator(
            delegate: feedCoordinatorDelegate,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher,
            selectedAssets: nil,
            themeManager: themeManager,
            selectedOrganisationsAndDepartments: nil,
            mainAppCoordinator: mainAppCoordinator
        ).editPost(feed: feed)
    }
    
    private func showDeletePostConfirmation(_ feedIdentifier : Int64, revertUserPoints : Bool){
        let deleteConfirmationDrawer = DeletePostConfirmationDrawer(
            nibName: "DeletePostConfirmationDrawer",
            bundle: Bundle(for: DeletePostConfirmationDrawer.self)
        )
        deleteConfirmationDrawer.themeManager = themeManager
        deleteConfirmationDrawer.targetFeed = targetFeedItem
        deleteConfirmationDrawer.isPostTypeAppreciation = revertUserPoints
        deleteConfirmationDrawer.deletePressedCompletion = {[weak self] in
            print("<<<<<<<<< proceed with feed delete \(feedIdentifier)")
            if let unwrappedSelf = self{
                PostDeleteWorker(networkRequestCoordinator: unwrappedSelf.requestCoordinator).deletePost(feedIdentifier, revertUserPoints: revertUserPoints) { (result) in
                    switch result{
                    case .Success(result: _):
                        DispatchQueue.main.async {[weak self] in
                            if let feedItem = self?.targetFeedItem{
                                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                                    if let post = ((feedItem as? RawObjectProtocol)?.getManagedObject() as? ManagedPost){
                                        CFFCoreDataManager.sharedInstance.manager.deleteManagedObject(managedObject: post, context: CFFCoreDataManager.sharedInstance.manager.privateQueueContext)
                                        CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                            print("<<<<<<<<<<<<<poll deleted suceessfully")
                                            CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                            DispatchQueue.main.async {
                                                ErrorDisplayer.showError(errorMsg: "Deleted successfully.".localized) { (_) in
                                                    if self?.showDisplayOptions == .Appreciation {
                                                        self?.navigationController?.popViewController(animated: true)
                                                    }else{
                                                        self?.feedCoordinatorDelegate.removeFeedDetail()
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(error: _):
                        print("<<<<< Unable to delete post")
                    }
                }
            }
        }
        do{
            try deleteConfirmationDrawer.presentDrawer()
        }catch {
            
        }
        
    }
    
    private func showReportAbuseConfirmation(_ feedIdentifier : Int64){
        let reportAbuseConfirmationDrawer = ReportAbuseConfirmationDrawer(
            nibName: "ReportAbuseConfirmationDrawer",
            bundle: Bundle(for: ReportAbuseConfirmationDrawer.self)
        )
        reportAbuseConfirmationDrawer.themeManager = themeManager
        reportAbuseConfirmationDrawer.targetFeed = targetFeedItem
        reportAbuseConfirmationDrawer.confirmPressedCompletion = {notes in
            print("<<<<<<<<< proceed with feed delete \(feedIdentifier)")
            ReportAbuseWorker(networkRequestCoordinator: self.requestCoordinator).reportAbusePost(feedIdentifier, notes: notes) { (result) in
                DispatchQueue.main.async {
                    switch result{
                    case .Success(_):
                        ErrorDisplayer.showError(errorMsg: "Reported successfully.".localized) { (_) in}
                    case .SuccessWithNoResponseData:
                        fallthrough
                    case .Failure(_):
                        ErrorDisplayer.showError(errorMsg: "Failed to report, please try again.".localized) { (_) in}
                    }
                }
                
            }
        }
        do{
            try reportAbuseConfirmationDrawer.presentDrawer()
        }catch {
            
        }
    }
    
    func showLikedByUsersList() {
        let likeListVC = LikeListViewController(
            feedIdentifier: targetFeedItem.feedIdentifier,
            requestCoordinator: requestCoordinator,
            mediaFetcher: mediaFetcher
        )
        feedCoordinatorDelegate.showPostLikeList(likeListVC, presentationOption: .Navigate) { (topBarModel) in
            likeListVC.containerTopBarModel = topBarModel
        }
    }
    
}

extension FeedsDetailViewController : ASChatBarViewDelegate{
    func finishedPresentingOverKeyboard() {
        
    }
    
    func addAttachmentButtonPressed() {
        
    }
    
    func removeAttachment() {
        
    }
    
    func rightButtonPressed(_ chatBar: ASChatBarview) {
        if let message = chatBar.messageTextView?.text{
            FeedCommentPostWorker(networkRequestCoordinator: requestCoordinator).postComment(
                comment: PostbaleComment(
                    feedId: targetFeedItem.feedIdentifier,
                    commentText: chatBar.taggedMessaged),
                isPostEditing: chatBar.isEditCommentEnabled,
                commentID: chatBar.commentID) { (result) in
                        DispatchQueue.main.async {
                            switch result{
                            case .Success(let result):
                                CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                                    let post = ((self.targetFeedItem as? RawObjectProtocol)?.getManagedObject() as! ManagedPost)
                                    post.numberOfComments =  chatBar.isEditCommentEnabled ? post.numberOfComments : post.numberOfComments + 1
                                    chatBar.isEditCommentEnabled = false
                                    ASMentionCoordinator.shared.clearMentionsTextView()
                                    self.targetFeedItem = post.getRawObject() as! RawFeed
                                    let _ = FeedComment(input: result).getManagedObject() as! ManagedPostComment
                                    CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                                        CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                                    }
                                }
                            case .SuccessWithNoResponseData:
                                print("comment posted successfully")
                            case .Failure(let error):
                                ErrorDisplayer.showError(errorMsg: error.displayableErrorMessage()) { (_) in
                                    
                                }
                                chatBar.messageTextView?.text = message
                            }
                        }
            }
        }
    }
    
}

extension FeedsDetailViewController:  NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // begin update to table
        feedDetailTableView?.beginUpdates()
    }
    
    // object changed
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let unwrappedInsertedIndexpath = newIndexPath {
                let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                feedDetailTableView?.insertRows(at: [translatedIndexpath], with: .fade)
            }
        case .delete:
            if let unwrappedInsertedIndexpath = indexPath {
                let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                feedDetailTableView?.deleteRows(at: [translatedIndexpath], with: .fade)
            }
        case .update:
            if let unwrappedInsertedIndexpath = indexPath {
                let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                feedDetailTableView?.reloadRows(at: [translatedIndexpath], with: .none)
            }
        case .move:
            if let unwrappedInsertedIndexpath = indexPath {
                if let unwrappedNewindexpath = newIndexPath {
                    let translatedIndexpath = IndexPath(row: unwrappedInsertedIndexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                    let translatedNewIndexpath = IndexPath(row: unwrappedNewindexpath.row, section: feedDetailSectionFactory.getCommentsSectionIndex())
                    feedDetailTableView?.deleteRows(at: [translatedIndexpath], with: .none)
                    feedDetailTableView?.insertRows(at: [translatedNewIndexpath], with: .none)
                }
            }
        @unknown default:
            fatalError("unknown NSFetchedResultsChangeType")
        }
    }
    
    // did change
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {[weak self] in
            self?.feedDetailSectionFactory.reloadToShowLikeAndCommentCountUpdate()
            self?.feedDetailSectionFactory.reloadToCommentCountHeader()
        }
        feedDetailTableView?.endUpdates()
    }
}
extension FeedsDetailViewController : EditCommentTypeProtocol,DeleteCommentProtocol{
    func deleteCommentPressed(commentID: Int64) {
        deleteComment(commentIdentifier: commentID)
    }
    
    func selectedFilterType(selectedType: EditCommentType, commentIdentifier: Int64, chatMessage: String) {
        switch selectedType {
        case .Edit:
//            commentBarView?.placeholder = ""
            commentBarView?.isEditCommentEnabled = true
            commentBarView?.commentID = commentIdentifier
            ASMentionCoordinator.shared.getPresentableMentionText(chatMessage, completion: { (attr) in
                commentBarView?.messageTextView?.attributedText = attr
            })
            commentBarView?.becomeFirstResponder()
        case .Delete:
            let deleteBottomSheet = DeleteCommentDrawer(nibName: "DeleteCommentDrawer", bundle: Bundle(for: DeleteCommentDrawer.self))
            deleteBottomSheet.delegate = self
            deleteBottomSheet.commentId = commentIdentifier
            deleteBottomSheet.modalPresentationStyle = .overCurrentContext
            self.present(deleteBottomSheet, animated: true)
            
        }
    }
}
extension FeedsDetailViewController : Click3DotsByMeFilterTypeProtocol {
    func selectedFilterType(selectedType: Click3DotsByMeFilterType, feedIdentifier: Int64, isPostAlreadyPinned: Bool) {
        switch selectedType {
        case .Edit:
            self.openFeedEditor(targetFeedItem)
        case .Pin:
            self.pinToPost(feedIdentifier: feedIdentifier, isAlreadyPinned: isPostAlreadyPinned)
        case .Delete:
            self.showDeletePostConfirmation(feedIdentifier, revertUserPoints: false)
        case .ReportAbuse:
            self.showReportAbuseConfirmation(feedIdentifier)
        }
    }
}
extension FeedsDetailViewController : AppreciationBottomSheetTypeProtocol {
    func selectedFilterType(selectedType: AppreciationBottomSheetType, feedIdentifier: Int64) {
        switch selectedType {
        case .Delete:
            self.showDeletePostConfirmation(feedIdentifier, revertUserPoints: false)
        case .ReportAbuse:
            self.showReportAbuseConfirmation(feedIdentifier)
        case .DeleteWithPoints:
            self.showDeletePostConfirmation(feedIdentifier, revertUserPoints: true)
        }
    }
}
