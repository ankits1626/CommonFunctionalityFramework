//
//  PostEditorCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol PostEditorCellFactoryDatasource : AnyObject{
    func getTargetPost() -> EditablePostProtocol?
}

protocol PostEditorCellFactoryDelegate : AnyObject {
    func reloadTextViewContainingRow(indexpath : IndexPath)
    func updatePostTitle( title : String?)
    func updatePostDescription( decription: String?)
    func removeSelectedMedia(index : Int, mediaSection: EditableMediaSection)
    func removeAttachedGif()
    func savePostOption(index : Int, option: String?)
    func activeDaysForPollChanged(_ days : Int)
    func showUserListForTagging(searckKey : String, textView: UITextView, pickerDelegate : TagUserPickerDelegate?)
    func dismissUserListForTagging(completion :(() -> Void))
    func updateTagPickerFrame(_ textView: UITextView?)
}

struct PostEditorCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    weak var datasource: PostEditorCellFactoryDatasource?
}

struct PostEditorCellLoadDataModel {
    var targetIndexpath : IndexPath
    var targetCell : UITableViewCell
    var targetTableView: UITableView?
    var datasource: PostEditorCellFactoryDatasource
    var delegate : PostEditorCellFactoryDelegate?
    var localMediaManager : LocalMediaManager?
    var postImageMapper : EditablePostMediaRepository
    weak var themeManager: CFFThemeManagerProtocol?
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
    weak var themeManager: CFFThemeManagerProtocol?
}

enum PostEditorSection : Int {
    case Title = 0
    case Description
    case Media
    case AttachedGif
    case PollOptions
    case PollActiveForDays
}

class PostEditorCellFactory {
    
    var input : InitPostEditorCellFactoryModel!
    
    lazy var cachedCellCoordinators: [String : PostEditorCellCoordinatorProtocol] = {
        return [
            FeedEditorTitleTableViewCellType().cellIdentifier : FeedEditorTitleTableViewCellCoordinator(),
            FeedEditorDescriptionTableViewCellType().cellIdentifier : FeedEditorDescriptionTableViewCellCoordinator(),
            MultipleMediaTableViewCellType().cellIdentifier : FeedEditorAttachedMutipleMediaTableViewCellCoordinator(),
            FeedGifTableViewCellType().cellIdentifier : FeedEditorAttachedGifTableViewCellCoordinator(),
            FeedEditorPollOptionTableViewCellType().cellIdentifier : FeedEditorPollOptionTableViewCellCoordinator(),
            PollsActiveDaysTableViewCellType().cellIdentifier : PollsActiveDaysTableViewCellCoordinator()
        ]
    }()
    
//    private lazy var headerCoordinator: FeedEditorHeaderCoordinator = {
//        return FeedEditorHeaderCoordinator(dataSource: input.datasource)
//    }()
    
    var headerCoordinator: FeedEditorHeaderCoordinator
    init(_ input : InitPostEditorCellFactoryModel) {
        self.input = input
        headerCoordinator = FeedEditorHeaderCoordinator(dataSource: input.datasource)
    }
    
    func clear(){
        input = nil
    }
    deinit{
        debugPrint("************  PostEditorCellFactory deinit")
    }
    
    func registerTableToAllPossibleCellTypes(_ targetTableView : UITableView?) {
        cachedCellCoordinators.forEach { (cellCoordinator) in
            targetTableView?.register(
                cellCoordinator.value.cellType.cellNib,
                forCellReuseIdentifier: cellCoordinator.value.cellType.cellIdentifier
            )
        }
        registerTableViewForHeaderView(targetTableView)
    }
    
    private func registerTableViewForHeaderView(_ tableView : UITableView?){
        tableView?.register(
            UINib(nibName: "FeedDetailHeader", bundle: Bundle(for: FeedDetailHeader.self)),
            forHeaderFooterViewReuseIdentifier: "FeedDetailHeader"
        )
    }
    
    func getNumberOfSection() -> Int {
        return getAvailablePostEditorSections().count
    }
    
    func numberOfRowsInSection(_ section : Int) -> Int {
        if getCurrentSection(section) == .PollOptions{
            return 4
        }
        return 1
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = getCellCoordinator(getCurrentSection(indexPath.section)).getCell(
            PostEditorCellDequeueModel(
                targetIndexpath: indexPath,
                targetTableView: tableView,
                datasource: input.datasource!
            )
        )
        cell.backgroundColor = .clear
        if let containerdCell = cell as? FeedsCustomCellProtcol{
            containerdCell.containerView?.backgroundColor = .white
        }
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        getCellCoordinator(getCurrentSection(indexPath.section)).loadDataCell(
            PostEditorCellLoadDataModel(
                targetIndexpath: indexPath,
                targetCell: cell,
                targetTableView: input.targetTableView,
                datasource: input.datasource!,
                delegate: input.delegate,
                localMediaManager: input.localMediaManager,
                postImageMapper: input.postImageMapper!,
                themeManager: input.themeManager
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
    
    func getHeightOfViewForSection(section: Int) -> CGFloat {
        return headerCoordinator.getHeight(section: getCurrentSection(section))
//        return headerCoordinator.getHeight(section: PostEditorSection(rawValue: section)!)
        
    }
    
    func getViewForHeaderInSection(section: Int, tableView: UITableView) -> UIView? {
        return headerCoordinator.getHeader(input: GetPostEditorDetailtableHeaderInput(
            section: getCurrentSection(section),
            table: tableView
            )
        )
    }
    
}

extension PostEditorCellFactory{
    private func getAvailablePostEditorSections() -> [PostEditorSection]{
        var sections = [PostEditorSection.Title]
        
        if let postType = input.datasource?.getTargetPost()?.postType{
            switch postType {
            case .Poll:
                sections.append(PostEditorSection.PollOptions)
                sections.append(.PollActiveForDays)
            case .Post:
                sections.append(.Description)
            }
        }
        
        if let shouldDisplayMediaSection = input.postImageMapper?.shouldDisplayMediaSection(input.datasource?.getTargetPost()),
            shouldDisplayMediaSection{
            sections.append(.Media)
        }
        
        if let shouldDisplayGifSection = input.datasource?.getTargetPost()?.isGifAttached(),
            shouldDisplayGifSection{
            sections.append(.AttachedGif)
        }
        
        return sections
    }
    
    private func getCellCoordinator(_ section : PostEditorSection) -> PostEditorCellCoordinatorProtocol{
        switch section {
        case .Title:
            return cachedCellCoordinators[FeedEditorTitleTableViewCellType().cellIdentifier]!
        case .Description:
            return cachedCellCoordinators[FeedEditorDescriptionTableViewCellType().cellIdentifier]!
        case .PollOptions:
            return cachedCellCoordinators[FeedEditorPollOptionTableViewCellType().cellIdentifier]!
        case .Media:
            return cachedCellCoordinators[MultipleMediaTableViewCellType().cellIdentifier]!
        case .PollActiveForDays:
            return cachedCellCoordinators[PollsActiveDaysTableViewCellType().cellIdentifier]!
        case .AttachedGif:
            return cachedCellCoordinators[FeedGifTableViewCellType().cellIdentifier]!
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
