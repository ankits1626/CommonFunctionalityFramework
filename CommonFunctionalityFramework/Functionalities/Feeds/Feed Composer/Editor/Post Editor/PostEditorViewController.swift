//
//  PostEditorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol EditablePostProtocol {
    var title : String? {set get}
    var postDesciption : String? {set get}
    //var attachedMedia: [FeedMediaItemProtocol]?{set get}
    var selectedMediaItems : [LocalSelectedMediaItem]? {set get}
}



class PostEditorViewController: UIViewController {
    var containerTopBarModel : EditorContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    @IBOutlet weak var postEditorTable : UITableView?
    
    lazy var postCoordinator: PostCoordinator = {
        return PostCoordinator(postObsever: cellFactory)
    }()
    private lazy var cellFactory: PostEditorCellFactory = {
        return PostEditorCellFactory(InitPostEditorCellFactoryModel(
            datasource: self,
            delegate: self,
            localMediaManager: localMediaManager,
            targetTableView: postEditorTable))
    }()
    
    private lazy var localMediaManager: LocalMediaManager = {
        return LocalMediaManager()
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        setupTableView()
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
    
    private func setupContainerTopbar(){
        containerTopBarModel?.title?.text = "CREATE POST"
        containerTopBarModel?.cameraButton?.setImage(
            UIImage(named: "camera", in: Bundle(for: PostEditorViewController.self), compatibleWith: nil),
            for: .normal
        )
        containerTopBarModel?.cameraButton?.tintColor = .black
        containerTopBarModel?.cameraButton?.addTarget(self, action: #selector(initiateMediaAttachment), for: .touchUpInside)
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
}


extension PostEditorViewController : PostEditorCellFactoryDatasource{
    func getTargetPost() -> EditablePostProtocol? {
        return postCoordinator.getCurrentPost()
    }
    
}
extension PostEditorViewController : PostEditorCellFactoryDelegate{
    func removeSelectedMedia(index: Int) {
        postCoordinator.removeSelectedMedia(index: index)
    }
    
    func updatePostTile(title: String?) {
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
        //postEditorTable?.reloadRows(at: [indexpath], with: .none)
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
