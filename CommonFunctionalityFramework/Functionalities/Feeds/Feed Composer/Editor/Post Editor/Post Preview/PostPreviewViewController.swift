//
//  PostPreviewViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 28/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

struct FeedPreviewInitModel{
    weak var requestCoordinator: CFFNetworkRequestCoordinatorProtocol?
    weak var editorRouter : PostEditorRouter?
    var selectedOrganisationsAndDepartments: FeedOrganisationDepartmentSelectionModel?
    var selectedOrganisationsAndDepartmentsDisplayable : FeedOrganisationDepartmentSelectionDisplayModel?
    weak var themeManager: CFFThemeManagerProtocol?
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var post : PreviewablePost
    weak var datasource : PostEditorCellFactoryDatasource?
    weak var localMediaManager : LocalMediaManager?
    weak var postImageMapper : EditablePostMediaRepository?
    weak var delegate: PostEditorCellFactoryDelegate?
    weak var eventListener : PostPreviewViewEventListener?
    var sharePostOption : SharePostOption
}


protocol PostPreviewViewEventListener : AnyObject{
    func postTriggered(_ completion:@escaping ()-> Void)
}

class PostPreviewViewController: UIViewController {
    var containerTopBarModel : GenericContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    
    private let initModel : FeedPreviewInitModel
    private var loader = CommonLoader()
    @IBOutlet private weak var previewTableview : UITableView?
    @IBOutlet private weak var postButton : UIButton?
    private lazy var listManager: PostPreviewListManager = {[weak self] in
        return PostPreviewListManager(
            PostPreviewListManagerInitModel(
                targetTableView: previewTableview,
                feedDataSource: self,
                themeManager: initModel.themeManager,
                mediaFetcher: initModel.mediaFetcher,
                datasource: initModel.datasource,
                localMediaManager: initModel.localMediaManager,
                postImageMapper: initModel.postImageMapper,
                delegate: nil,
                router: initModel.editorRouter
            )
        )
    }()
    
    init(_ previewInitModel : FeedPreviewInitModel) {
        self.initModel = previewInitModel
        super.init(nibName: "PostPreviewViewController", bundle: Bundle(for: PostPreviewViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("PostPreviewViewController init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnViewLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        listManager.clear()
    }
    private func setupContainerTopbar(){
        containerTopBarModel?.container?.backgroundColor = .clear
        containerTopBarModel?.title?.text = "PREVIEW POST".localized.uppercased()
        containerTopBarModel?.rightButton?.tintColor = .black
        containerTopBarModel?.rightButton?.setImage(
            UIImage(named: "cff_edit", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
            for: .normal
        )
        containerTopBarModel?.rightButton?.addTarget(self, action: #selector(goBackToEditor), for: .touchUpInside)
    }
    
    @objc private func goBackToEditor(){
        initModel.editorRouter?.routeToEditor()
    }
    
    private func setupOnViewLoad(){
        setupPostButton()
        setupTable()
    }
    
    private func setupTable(){
        listManager.loadData()
    }
    
    private func setupPostButton(){
        postButton?.setTitle("POST".localized, for: .normal)
        postButton?.titleLabel?.font = UIFont.Button
        postButton?.titleLabel?.tintColor = .buttonTextColor
        postButton?.backgroundColor = initModel.themeManager?.getControlActiveColor() ?? .buttonColor
        postButton?.curvedCornerControl()
    }
    
    @IBAction private func postButtonTapped(){
        loader.showActivityIndicator(view)
        initModel.eventListener?.postTriggered {[weak self] in
            if let unwrappedSelf = self{
                unwrappedSelf.loader.hideActivityIndicator(unwrappedSelf.view)
            }
        }
    }
    
    deinit{
        debugPrint("<<<<<<<<< preview deinit not called")
    }
}


extension PostPreviewViewController : FeedsDatasource{
    func getPostShareOption() -> SharePostOption {
        return initModel.sharePostOption
    }
    
    func getPostSharedWithOrgAndDepartment() -> FeedOrganisationDepartmentSelectionDisplayModel? {
        return initModel.selectedOrganisationsAndDepartmentsDisplayable
    }
    
    func getNumberOfItems() -> Int {
        return 0
    }
    
    func getFeedItem(_ index: Int) -> FeedsItemProtocol {
        return initModel.post
    }
    
    func getFeedItem() -> FeedsItemProtocol! {
        return initModel.post
    }
    
    func getClappedByUsers() -> [ClappedByUser]? {
        return nil
    }
    
    func getCommentProvider() -> FeedsDetailCommentsProviderProtocol? {
        return nil
    }
    
    func showShowFullfeedDescription() -> Bool {
        return true
    }
    
    func shouldShowMenuOptionForFeed() -> Bool {
        return false
    }
    
    
}
