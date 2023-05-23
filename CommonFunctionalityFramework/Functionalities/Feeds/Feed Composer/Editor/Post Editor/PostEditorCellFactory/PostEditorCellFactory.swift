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
    func createdPostType(_ isEnabled: Bool?)
    func openPhotoLibrary()
    func openGif()
    func openECard()
    func removeAttachedECard()
    func numberOfRowsIncrement(number: Int)
}

struct PostEditorCellDequeueModel {
    var targetIndexpath : IndexPath
    var targetTableView : UITableView
    weak var datasource: PostEditorCellFactoryDatasource?
    weak var mediaFetcher : CFFMediaCoordinatorProtocol!
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
    weak var mediaFetcher : CFFMediaCoordinatorProtocol!
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
    weak var mediaFetcher : CFFMediaCoordinatorProtocol?
}

enum PostEditorSection : Int {
    case Title = 0
    case Description
    case AddMedia
    case PostType
    case ECardMedia
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
            PollsActiveDaysTableViewCellType().cellIdentifier : PollsActiveDaysTableViewCellCoordinator(),
            SelectPostMediaTableViewCellType().cellIdentifier : SelectMediaTableViewCellCoordinator(),
            SelectPostTypeTableViewCellType().cellIdentifier : SelectPostTypeTableCellCordinator(),
            AddECardTableViewCellType().cellIdentifier : AddECardTypeTableCellCordinator()
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
    
    func numberOfRowsInSection(_ section : Int, _ rows: Int) -> Int {
        if getCurrentSection(section) == .PollOptions{
            return rows
        }
        return 1
    }
    
    func getCell(indexPath : IndexPath, tableView: UITableView) -> UITableViewCell {
        let cell = getCellCoordinator(getCurrentSection(indexPath.section)).getCell(
            PostEditorCellDequeueModel(
                targetIndexpath: indexPath,
                targetTableView: tableView,
                datasource: input.datasource!,
                mediaFetcher: input.mediaFetcher
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
                themeManager: input.themeManager,
                mediaFetcher: input.mediaFetcher
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
                
            case .Greeting:
                sections.append(.Description)
            }
        }
        
        if let shouldDisplayECard = input.datasource?.getTargetPost()?.isECardAttached(),
           shouldDisplayECard{
            sections.append(.ECardMedia)
        }
        
        if let shouldDisplayMediaSection = input.postImageMapper?.shouldDisplayMediaSection(input.datasource?.getTargetPost()),
            shouldDisplayMediaSection{
            sections.append(.Media)
        }
        
        if let shouldDisplayGifSection = input.datasource?.getTargetPost()?.isGifAttached(),
            shouldDisplayGifSection{
            sections.append(.AttachedGif)
        }
        
        
        if let postType = input.datasource?.getTargetPost()?.postType{
            switch postType {
            case .Poll:
                sections.append(.PostType)
            case .Post:
                sections.append(.AddMedia)
                sections.append(.PostType)
            case .Greeting:
                sections.append(.AddMedia)
                sections.append(.PostType)
            }
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
        case .AddMedia:
            return cachedCellCoordinators[SelectPostMediaTableViewCellType().cellIdentifier]!
        case .PostType:
            return cachedCellCoordinators[SelectPostTypeTableViewCellType().cellIdentifier]!
        case .ECardMedia:
            return cachedCellCoordinators[AddECardTableViewCellType().cellIdentifier]!
        }
    }
}

extension PostEditorCellFactory : PostObserver{
    func attachedECardMediaUpdated() {
        input.targetTableView?.reloadData()
    }
    
    func removedAttachedMediaitemAtIndex(index: Int) {
        if let coordinator = cachedCellCoordinators[MultipleMediaTableViewCellType().cellIdentifier ] as? FeedEditorAttachedMutipleMediaTableViewCellCoordinator{
            coordinator.removeSelectedMediItem(PostEditorRemoveAttachedMediaDataModel(targetIndex: index))
        }
    }
    
    func mediaAttachedToPost() {
        input.targetTableView?.reloadData()
    }
    
    func attachedMediaUpdated() {
        input.targetTableView?.reloadData()
    }
    
    func allAttachedMediaRemovedFromPost() {
        input.targetTableView?.reloadData()
    }
}
