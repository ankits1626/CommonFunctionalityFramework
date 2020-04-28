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
    func updatePostTitle( title : String?)
    func updatePostDescription( decription: String?)
    func removeSelectedMedia(index : Int, mediaSection: EditableMediaSection)
    func savePostOption(index : Int, option: String?)
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
    var postImageMapper : EditablePostMediaRepository
}

struct PostEditorRemoveAttachedMediaDataModel {
    var targetIndex : Int
}

struct PostEditorGetHeightModel {
    var targetIndexpath : IndexPath
    var datasource: PostEditorCellFactoryDatasource
    weak var postImageMapper : EditablePostMediaRepository?
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

struct InitPostEditorCellFactoryModel {
    weak var datasource : PostEditorCellFactoryDatasource?
    weak var delegate : PostEditorCellFactoryDelegate?
    weak var localMediaManager : LocalMediaManager?
    weak var targetTableView : UITableView?
    weak var postImageMapper : EditablePostMediaRepository?
}

class PostEditorCellFactory {
    enum PostEditorSection : Int {
        case Title = 0
        case Description
        case Media
        case Poll
    }
    
    var input : InitPostEditorCellFactoryModel
    
    lazy var cachedCellCoordinators: [String : PostEditorCellCoordinatorProtocol] = {
        return [
            FeedEditorTitleTableViewCellType().cellIdentifier : FeedEditorTitleTableViewCellCoordinator(),
            FeedEditorDescriptionTableViewCellType().cellIdentifier : FeedEditorDescriptionTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : FeedEditorAttachedMutipleMediaTableViewCellCoordinator(),
            FeedEditorPollOptionTableViewCellType().cellIdentifier : FeedEditorPollOptionTableViewCellCoordinator()
        ]
    }()
    
    init(_ input : InitPostEditorCellFactoryModel) {
        self.input = input
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
        if getCurrentSection(section) == .Poll{
            return 4
        }
        return 1
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        return getCellCoordinator(getCurrentSection(indexPath.section)).getCell(
            PostEditorCellDequeueModel(
                targetIndexpath: indexPath,
                targetTableView: tableView,
                datasource: input.datasource!
            )
        )
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        getCellCoordinator(getCurrentSection(indexPath.section)).loadDataCell(
            PostEditorCellLoadDataModel(
                targetIndexpath: indexPath,
                targetCell: cell,
                datasource: input.datasource!,
                delegate: input.delegate,
                localMediaManager: input.localMediaManager,
                postImageMapper: input.postImageMapper!
            )
        )
    }
    
    func getHeight(indexPath: IndexPath) -> CGFloat {
        return getCellCoordinator(getCurrentSection(indexPath.section)).getHeight(
            PostEditorGetHeightModel(
                targetIndexpath: indexPath,
                datasource: input.datasource!,
                postImageMapper: input.postImageMapper)
        )
    }
    
    private func getCurrentSection(_ index : Int) -> PostEditorSection{
        let availableSections = getAvailablePostEditorSections()
        return availableSections[index]
    }
    
}

extension PostEditorCellFactory{
    private func getAvailablePostEditorSections() -> [PostEditorSection]{
        var sections = [PostEditorSection.Title]
        
        if let postType = input.datasource?.getTargetPost()?.postType{
            switch postType {
            case .Poll:
                sections.append(PostEditorCellFactory.PostEditorSection.Poll)
            case .Post:
                sections.append(.Description)
            }
        }
        
        if let shouldDisplayMediaSection = input.postImageMapper?.shouldDisplayMediaSection(input.datasource?.getTargetPost()),
            shouldDisplayMediaSection{
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
        case .Poll:
            return cachedCellCoordinators[FeedEditorPollOptionTableViewCellType().cellIdentifier]!
        case .Media:
            return cachedCellCoordinators[MultipleMediaTableViewCellType().cellIdentifier]!
        }
    }
}

extension PostEditorCellFactory : PostObserver{
    func removedAttachedMediaitemAtIndex(index: Int) {
        if let coordinator = cachedCellCoordinators[MultipleMediaTableViewCellType().cellIdentifier ] as? FeedEditorAttachedMutipleMediaTableViewCellCoordinator{
            coordinator.removeSelectedMediItem(PostEditorRemoveAttachedMediaDataModel(targetIndex: index))
        }
    }
    
    func mediaAttachedToPost() {
        input.targetTableView?.reloadData()
        input.targetTableView?.scrollToRow(at: IndexPath(row: 0, section: PostEditorSection.Media.rawValue), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func attachedMediaUpdated() {
        input.targetTableView?.reloadSections(IndexSet(integer: PostEditorSection.Media.rawValue), with: .top)
        input.targetTableView?.scrollToRow(at: IndexPath(row: 0, section: PostEditorSection.Media.rawValue), at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func allAttachedMediaRemovedFromPost() {
        input.targetTableView?.reloadData()
    }
}
