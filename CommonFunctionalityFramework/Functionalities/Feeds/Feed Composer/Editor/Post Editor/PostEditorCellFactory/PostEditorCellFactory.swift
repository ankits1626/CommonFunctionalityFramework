//
//  PostEditorCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol PostEditorCellFactoryDatasource : class{
    func getTargetPost() -> EditablePostProtocol?
}

protocol PostEditorCellFactoryDelegate : class {
    func reloadTextViewContainingRow(indexpath : IndexPath)
    func updatePostTile( title : String?)
    func updatePostDescription( decription: String?)
}

struct PostEditorCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    var datasource: PostEditorCellFactoryDatasource
}

struct PostEditorCellLoadDataModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
    var datasource: PostEditorCellFactoryDatasource
    var delegate : PostEditorCellFactoryDelegate?
    var localMediaManager : LocalMediaManager?
}

struct PostEditorGetHeightModel {
    var targetIndexpath : IndexPath
    var datasource: PostEditorCellFactoryDatasource
}

protocol PostEditorCellCoordinatorProtocol {
    var cellType : FeedCellTypeProtocol {get}
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell
    func loadDataCell(_ inputModel: PostEditorCellLoadDataModel)
    func getHeight(_ inputModel: PostEditorGetHeightModel) -> CGFloat
}

extension PostEditorCellCoordinatorProtocol{
    func getCell(_ inputModel: PostEditorCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
}


class PostEditorCellFactory {
    enum PostEditorSection : Int {
        case Title = 0
        case Description
        case Media
    }
    
    weak var datasource : PostEditorCellFactoryDatasource?
    weak var delegate : PostEditorCellFactoryDelegate?
    weak var localMediaManager : LocalMediaManager?
    
    lazy var cachedCellCoordinators: [String : PostEditorCellCoordinatorProtocol] = {
        return [
            FeedEditorTitleTableViewCellType().cellIdentifier : FeedEditorTitleTableViewCellCoordinator(),
            FeedEditorDescriptionTableViewCellType().cellIdentifier : FeedEditorDescriptionTableViewCellCoordinator(),
            SingleImageTableViewCellType().cellIdentifier : SingleImageTableViewCellCoordinator(),
            SingleVideoTableViewCellType().cellIdentifier : SingleVideoTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : FeedEditorAttachedMutipleMediaTableViewCellCoordinator(),
        ]
    }()
    
    init(_ datasource : PostEditorCellFactoryDatasource, delegate : PostEditorCellFactoryDelegate, localMediaManager : LocalMediaManager?) {
        self.datasource = datasource
        self.delegate = delegate
        self.localMediaManager = localMediaManager
    }
    
    
    
    func registerTableToAllPossibleCellTypes(_ targetTableView : UITableView?) {
        cachedCellCoordinators.forEach { (cellCoordinator) in
            targetTableView?.register(
                cellCoordinator.value.cellType.cellNib,
                forCellReuseIdentifier: cellCoordinator.value.cellType.cellIdentifier
            )
        }
    }
    
    func getNumberOfSection() -> Int {
        return getAvailablePostEditorSections().count
    }
    
    func numberOfRowsInSection(_ section : Int) -> Int {
        return 1
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        return getCellCoordinator(PostEditorSection(rawValue: indexPath.section)!).getCell(
            PostEditorCellDequeueModel(
                targetIndexpath: indexPath,
                targetTableView: tableView,
                datasource: datasource!
            )
        )
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        getCellCoordinator(PostEditorSection(rawValue: indexPath.section)!).loadDataCell(
            PostEditorCellLoadDataModel(
                targetIndexpath: indexPath,
                targetCell: cell,
                datasource: datasource!,
                delegate: delegate,
                localMediaManager: localMediaManager
            )
        )
    }
    
    func getHeight(indexPath: IndexPath) -> CGFloat {
        return getCellCoordinator(PostEditorSection(rawValue: indexPath.section)!).getHeight(
            PostEditorGetHeightModel(targetIndexpath: indexPath, datasource: datasource!)
        )
    }
    
    func insertAttachedMediaSection(_ tableView : UITableView?) {
        tableView?.insertSections(IndexSet(integer: PostEditorSection.Media.rawValue), with: .top)
        tableView?.scrollToRow(at: IndexPath(row: 0, section: PostEditorSection.Media.rawValue), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func reloadAttachedMediaSections(_ tableView : UITableView?) {
        tableView?.reloadSections(IndexSet(integer: PostEditorSection.Media.rawValue), with: .top)
        tableView?.scrollToRow(at: IndexPath(row: 0, section: PostEditorSection.Media.rawValue), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func deleteAttachedMediaSections(_ tableView : UITableView?) {
        tableView?.deleteSections(IndexSet(integer: PostEditorSection.Media.rawValue), with: .top)
        tableView?.scrollToRow(at: IndexPath(row: 0, section: PostEditorSection.Media.rawValue), at: UITableView.ScrollPosition.bottom, animated: true)
    }
}

extension PostEditorCellFactory{
    private func getAvailablePostEditorSections() -> [PostEditorSection]{
        var sections = [PostEditorSection.Title , .Description]
        if let _ = datasource?.getTargetPost()?.selectedMediaItems{
            sections.append(.Media)
        }
        return sections
    }
    
    private func getCellCoordinator(_ section : PostEditorSection) -> PostEditorCellCoordinatorProtocol{
        switch section {
        case .Title:
            return cachedCellCoordinators[FeedEditorTitleTableViewCellType().cellIdentifier]!
        case .Description:
            return cachedCellCoordinators[FeedEditorDescriptionTableViewCellType().cellIdentifier]!
        case .Media:
            let attachedMedia : [LocalSelectedMediaItem] = (datasource?.getTargetPost()?.selectedMediaItems)!
            if attachedMedia.count == 1{
                if attachedMedia.first!.mediaType == .video{
                    return cachedCellCoordinators[SingleVideoTableViewCellType().cellIdentifier]!
                }else{
                    return cachedCellCoordinators[SingleImageTableViewCellType().cellIdentifier]!
                }
            }else{
                return cachedCellCoordinators[MultipleMediaTableViewCellType().cellIdentifier]!
            }
        }
    }
}
