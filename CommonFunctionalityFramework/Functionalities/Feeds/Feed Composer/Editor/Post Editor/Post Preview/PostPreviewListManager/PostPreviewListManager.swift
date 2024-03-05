//
//  PostPreviewListManager.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 29/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit
import RewardzCommonComponents

struct PostPreviewListManagerInitModel {
    weak var targetTableView : UITableView?
    weak var feedDataSource : FeedsDatasource?
    weak var themeManager: CFFThemeManagerProtocol?
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    weak var datasource : PostEditorCellFactoryDatasource?
    weak var localMediaManager : LocalMediaManager?
    weak var postImageMapper : EditablePostMediaRepository?
    weak var delegate: PostEditorCellFactoryDelegate?
    weak var router : PostEditorRouter?
}

enum PostPreviewSection : Int, CaseIterable{
    case PostInfo = 0
    case ShareWithInfoSection
}


class PostPreviewListManager : NSObject{
    var postPreviewFactory: PostPreviewSectionFactory!
    private var initModel : PostPreviewListManagerInitModel!
    
    init(_ initModel : PostPreviewListManagerInitModel){
        self.initModel = initModel
        super.init()
        postPreviewFactory = PostPreviewSectionFactory(
            PostPreviewSectionFactoryInitModel(
                feedDataSource: initModel.feedDataSource,
                themeManager: initModel.themeManager,
                targetTableView: initModel.targetTableView,
                mediaFetcher: initModel.mediaFetcher,
                router: initModel.router
            )
        )
        setupTableView()
        
    }
    
    func clear(){
        postPreviewFactory.cleanup()
        postPreviewFactory = nil
        initModel = nil
    }
    private func setupTableView(){
        postPreviewFactory.setupTableView(initModel.targetTableView)
        initModel.targetTableView?.dataSource = self
        initModel.targetTableView?.delegate = self
    }
    
    func loadData(){
        initModel.targetTableView?.reloadData()
    }
    
    deinit{
        debugPrint("<<<<<<<<< preview list manager not called")
    }
}

extension PostPreviewListManager : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return PostPreviewSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postPreviewFactory.getNumberOfRowsFor(
            section: PostPreviewSection(rawValue: section)!,
            post: initModel.feedDataSource!.getFeedItem()
        )
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        postPreviewFactory.configureCell(cell: cell, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return postPreviewFactory.getCell(tableView: tableView, indexpath: indexPath, post: initModel.feedDataSource!.getFeedItem())
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return postPreviewFactory.getHeightOfCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return postPreviewFactory.getViewForHeaderInSection(section: section, tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return postPreviewFactory.getHeightOfViewForSection(section: section)
    }
}
