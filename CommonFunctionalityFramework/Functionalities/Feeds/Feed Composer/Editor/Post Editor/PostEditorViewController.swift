//
//  PostEditorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import SimpleCheckbox

class PostEditorViewController: UIViewController {
    var containerTopBarModel : EditorContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    private let postType: FeedType
    private let requestCoordinator: CFFNetwrokRequestCoordinatorProtocol
    
    @IBOutlet private weak var postEditorTable : UITableView?
    @IBOutlet private weak var createButton : UIButton?
    @IBOutlet private weak var postWithSameDepartmentCheckBox : Checkbox?
    @IBOutlet private weak var postWithSameDepartmentMessage: UILabel?
    
    lazy var postCoordinator: PostCoordinator = {
        return PostCoordinator(postObsever: cellFactory, postType: postType, editablePost: editablePost)
    }()
    lazy var imageMapper : EditablePostMediaRepository = {
        return EditablePostMediaRepository(input: EditablePostMediaMapperInitModel(
            datasource: self,
            localMediaManager: localMediaManager,
            mediaFetcher: mediaFetcher
            )
        )
    }()
    private lazy var cellFactory: PostEditorCellFactory = {
        return PostEditorCellFactory(InitPostEditorCellFactoryModel(
            datasource: self,
            delegate: self,
            localMediaManager: localMediaManager,
            targetTableView: postEditorTable,
            postImageMapper: imageMapper
            )
        )
    }()
    private weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    private lazy var localMediaManager: LocalMediaManager = {
        return LocalMediaManager()
    }()
    private let editablePost : EditablePostProtocol?
    
    init(postType: FeedType, requestCoordinator : CFFNetwrokRequestCoordinatorProtocol, post: EditablePostProtocol?, mediaFetcher: CFFMediaCoordinatorProtocol?){
        self.postType  = postType
        self.requestCoordinator = requestCoordinator
        self.editablePost = post
        self.mediaFetcher = mediaFetcher
        super.init(
            nibName: "PostEditorViewController"
            , bundle: Bundle(for: PostEditorViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    private func setup(){
        view.backgroundColor = .viewBackgroundColor
        setupTableView()
        setupCreateButton()
        setupPostWithDepartment()
    }
    
    private func setupPostWithDepartment() {
        postWithSameDepartmentCheckBox?.isEnabled = postCoordinator.isDepartmentSharedWithEditable()
        postWithSameDepartmentCheckBox?.checkmarkStyle = .tick
        postWithSameDepartmentCheckBox?.isChecked = postCoordinator.isPostWithSameDepartment()
        postWithSameDepartmentCheckBox?.valueChanged = {(isChecked) in
            self.postCoordinator.updatePostWithSameDepartment(isChecked)
        }
        
        postWithSameDepartmentMessage?.text = "Post with the same department only"
        postWithSameDepartmentMessage?.font = .Highlighter2
        
    }
    
    private func setupTableView(){
        postEditorTable?.tableFooterView = UIView(frame: CGRect.zero)
        postEditorTable?.rowHeight = UITableView.automaticDimension
        postEditorTable?.estimatedRowHeight = 140
        postEditorTable?.dataSource = self
        postEditorTable?.delegate = self
        cellFactory.registerTableToAllPossibleCellTypes(postEditorTable)
        postEditorTable?.reloadData()
    }
    
    private func setupCreateButton(){
        switch postType {
        case .Poll:
            createButton?.setTitle("CREATE POLL", for: .normal)
        case .Post:
            createButton?.setTitle("POST", for: .normal)
        }
        createButton?.titleLabel?.font = UIFont.Button
        createButton?.titleLabel?.tintColor = .buttonTextColor
        createButton?.backgroundColor = .buttonColor
    }
    
    private func setupContainerTopbar(){
        switch postType {
        case .Poll:
            containerTopBarModel?.title?.text = "CREATE POLL"
            containerTopBarModel?.cameraButton?.isHidden = true
        case .Post:
            containerTopBarModel?.title?.text = "CREATE POST"
            containerTopBarModel?.cameraButton?.setImage(
                UIImage(named: "camera", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
                for: .normal
            )
            containerTopBarModel?.cameraButton?.tintColor = .black
            containerTopBarModel?.cameraButton?.addTarget(self, action: #selector(initiateMediaAttachment), for: .touchUpInside)
        }
    }
    
    @objc private func initiateMediaAttachment(){
        let assetGridVC = AssetGridViewController(nibName: "AssetGridViewController", bundle: Bundle(for: AssetGridViewController.self))
        assetGridVC.localMediaManager = localMediaManager
        if let selectedItems = postCoordinator.getCurrentPost().selectedMediaItems{
            assetGridVC.selectedAssets = selectedItems
        }
        assetGridVC.assetSelectionCompletion = { (selectedMediaItems) in
            self.updatePostWithSelectedMediaSection(selectedMediaItems: selectedMediaItems)
        }
        present(assetGridVC, animated: true, completion: nil)
    }
    
    private func updatePostWithSelectedMediaSection(selectedMediaItems : [LocalSelectedMediaItem]?){
        postCoordinator.updateAttachedMediaItems(selectedMediaItems)
    }
    
    
    @IBAction func createButtonPressed(){
        do{
            try postCoordinator.checkIfPostReadyToPublish()
            PostImageDataMapper(localMediaManager).prepareMediaUrlMapForPost(
            self.postCoordinator.getCurrentPost()) { (localImageUrls, error) in
                 print("here")
                if let unwrappedUrls = localImageUrls{
                    self.postCoordinator.saveLocalMediUrls(unwrappedUrls)
                }
                if error == nil{
                    PostPublisher(networkRequestCoordinator: self.requestCoordinator).publisPost(
                    post: self.postCoordinator.getCurrentPost()) {[weak self] (callResult) in
                        DispatchQueue.main.async {
                            switch callResult{
                            case .Success(_):
                                self?.dismiss(animated: true, completion: nil)
                            case .SuccessWithNoResponseData:
                                ErrorDisplayer.showError(errorMsg: "Unable to post.") { (_) in

                                }
                            case .Failure(let error):
                                ErrorDisplayer.showError(errorMsg: "Unable to post due to \(error.displayableErrorMessage())") { (_) in

                                }
                            }
                        }
                    }
                }
                else{
                    print("<<<<<<<<<<<<<<<<<<< erorr observed \(error)")
                }
            }
        }catch let error{
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
                
            }
        }
    }
}


extension PostEditorViewController : PostEditorCellFactoryDatasource{
    func getTargetPost() -> EditablePostProtocol? {
        return postCoordinator.getCurrentPost()
    }
    
}
extension PostEditorViewController : PostEditorCellFactoryDelegate{
    func activeDaysForPollChanged(_ days: Int) {
        postCoordinator.updateActiveDayForPoll(days)
    }
    
    func savePostOption(index: Int, option: String?) {
        postCoordinator.savePostOption(index: index, option: option)
    }
    
    func removeSelectedMedia(index : Int, mediaSection: EditableMediaSection) {
        postCoordinator.removeMedia(index: index, mediaSection: mediaSection)
    }
    
    func updatePostTitle(title: String?) {
        postCoordinator.updatePostTile(title: title)
    }
    
    func updatePostDescription(decription: String?) {
        postCoordinator.updatePostDescription(decription: decription)
    }
    
    func reloadTextViewContainingRow(indexpath: IndexPath) {
        print("<< reload text view \(indexpath)")
        UIView.setAnimationsEnabled(false)
        postEditorTable?.beginUpdates()
        postEditorTable?.endUpdates()
        postEditorTable?.scrollToRow(at: indexpath, at: .bottom, animated: false)
        UIView.setAnimationsEnabled(true)
    }
}

extension PostEditorViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellFactory.getNumberOfSection()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellFactory.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory.getCell(indexPath:indexPath, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellFactory.configureCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellFactory.getHeight(indexPath: indexPath)
    }
}
