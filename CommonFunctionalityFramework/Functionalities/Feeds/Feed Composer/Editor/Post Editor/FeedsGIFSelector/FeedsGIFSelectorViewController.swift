//
//  FeedsGIFSelectorViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 09/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData
import FLAnimatedImage

protocol FeedsGIFSelectorDelegate : class {
    func finishedSelectingGif(_ gif: RawGif)
}

class FeedsGIFSelectorViewController: UIViewController {
    @IBOutlet private weak var gifSearchBar : UISearchBar?
    @IBOutlet private weak var gifCollection : UICollectionView?
    private var shouldReloadCollectionView : Bool = false
    private var blockOperations : [BlockOperation] = []
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    private var frc : NSFetchedResultsController<ManagedGifs>?
    private var lastFetchedGifs : FetchedGifModel = FetchedGifModel(fetchedRawGifs: nil, error: nil, nextPageState: FetchedGifNextPageState.Initial)
    
    private var isFetchingNextPage = false
    private var gifDownloadTasks = [URLSessionDataTask]()
    
    var requestCoordinator: CFFNetwrokRequestCoordinatorProtocol!
    weak var mediaFetcher: CFFMediaCoordinatorProtocol?
    weak var feedsGIFSelectorDelegate : FeedsGIFSelectorDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        view.clipsToBounds = true
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        setupSearchBar()
        setupCollectionView()
        clearExistingGifs {[weak self] in
            self?.initializeFRC()
            self?.loadGifs()
        }
    }
    
    private func setupSearchBar(){
        gifSearchBar?.backgroundColor = .clear
        gifSearchBar?.backgroundImage = UIImage()
        gifSearchBar?.barTintColor = .clear
        gifSearchBar?.placeholder = "Search Tenor"
    }
    
    private func setupCollectionView(){
        gifCollection?.register(
            UINib(nibName: "GifCollectionViewCell", bundle: Bundle(for: GifCollectionViewCell.self)),
            forCellWithReuseIdentifier: "GifCollectionViewCell"
        )
        gifCollection?.dataSource = self
        gifCollection?.delegate = self
    }
    
    private func initializeFRC() {
        let fetchRequest: NSFetchRequest<ManagedGifs> = ManagedGifs.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "createdTimeStamp", ascending: true)
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
            gifCollection?.reloadData()
        } catch let error {
            print("<<<<<<<<<< error \(error.localizedDescription)")
        }
    }
    
    private func clearExistingGifs(_ completion :@escaping (() -> Void)){
        CFFGifCacheManager.sharedInstance.dropCache()
        CFFCoreDataManager.sharedInstance.manager.deleteAllObjetcs(type: ManagedGifs.self) {
            DispatchQueue.main.async {
                CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                completion()
            }
        }
    }
    
    private func loadGifs(){
        GifFetcher(networkRequestCoordinator: requestCoordinator).fetchGifs(nextPageState: lastFetchedGifs.nextPageState, searchKey: gifSearchBar?.text) { [weak self](result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(result: let result):
                    self?.handleFetchedGifsResult(lastFetchedGifs: result)
                case .SuccessWithNoResponseData:
                    ErrorDisplayer.showError(errorMsg: "No record Found") { (_) in}
                case .Failure(error: let error):
                     ErrorDisplayer.showError(errorMsg: error.displayableErrorMessage()) { (_) in}
                }
            }
            
        }
    }
    
    private func handleFetchedGifsResult (lastFetchedGifs : FetchedGifModel){
        self.lastFetchedGifs = lastFetchedGifs
        loadFetchedGifs()
    }
    
    private func loadFetchedGifs(){
        if let fetchedGifs = lastFetchedGifs.fetchedRawGifs?["results"] as? [[String : Any]]{
            CFFCoreDataManager.sharedInstance.manager.privateQueueContext.perform {
                fetchedGifs.forEach { (aRawGif) in
                    let _ = RawGif(input: aRawGif).getManagedObject() as! ManagedGifs
                }
                CFFCoreDataManager.sharedInstance.manager.pushChangesToUIContext {
                    CFFCoreDataManager.sharedInstance.manager.saveChangesToStore()
                }
            }
        }
        DispatchQueue.main.async {[weak self] in
            self?.gifCollection?.reloadData()
        }
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: UIScreen.main.bounds.height * 3/4)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedsComposerDrawerError.UnableToGetTopViewController
        }
    }
}

extension FeedsGIFSelectorViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0{
            initiateAfterSearchBarEditing()
        }
       
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        initiateAfterSearchBarEditing()
        searchBar.resignFirstResponder()
    }
    
    private func initiateAfterSearchBarEditing(){
        gifDownloadTasks.forEach { (aTask) in
            aTask.cancel()
        }
        gifDownloadTasks = [URLSessionDataTask]()
        lastFetchedGifs = FetchedGifModel(fetchedRawGifs: nil, error: nil, nextPageState: FetchedGifNextPageState.Initial)
        clearExistingGifs {[weak self] in
            self?.loadGifs()
        }
    }
}

extension FeedsGIFSelectorViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = frc?.sections else {
            return 0
        }
        let sectionInfo = sections[0]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GifCollectionViewCell",
            for: indexPath) as? GifCollectionViewCell
            else { fatalError("unexpected cell in collection view")
        }
        //_ = frc?.object(at: IndexPath(item: indexPath.item, section: 0)).getRawObject() as? RawGif
        cell.identifierLabel?.isHidden = true
        if let rawGif = (frc?.object(at: IndexPath(item: indexPath.item, section: 0)).getRawObject() as? RawGif)?.getGifIconSourceUrl() {
            if let data = CFFGifCacheManager.sharedInstance.gifCache.object(forKey: rawGif as NSString) as Data?{
                cell.gifImage?.animatedImage = FLAnimatedImage(animatedGIFData: data)
            }else{
                cell.gifImage?.animatedImage = nil
                let task = URLSession.shared.dataTask(with: URLRequest(url: URL(string:rawGif)!)) { [weak self](data, _, _) in
                  DispatchQueue.main.async {
                    if let unwrappeData = data as NSData?{
                        CFFGifCacheManager.sharedInstance.gifCache.setObject(unwrappeData, forKey: rawGif as NSString)
                        if let visibleIndexpaths = self?.gifCollection?.indexPathsForVisibleItems,
                            visibleIndexpaths.contains(indexPath){
                            self?.gifCollection?.reloadItems(at: [indexPath])
                        }
                    }
                  }
                }
                gifDownloadTasks.append(task)
                task.resume()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var numberOfItems = 0
        if let sections = frc?.sections {
            numberOfItems =  sections[0].numberOfObjects
            if indexPath.item == (numberOfItems - 1){
                switch lastFetchedGifs.nextPageState {
                    
                case .Initial:
                    print("<<<<<<<<<<<<< initial")
                case .NextAvailable(_):
                    if isFetchingNextPage{
                        print("<<<<<<<<< lready fetching next page wait till its over")
                    }else{
                        GifFetcher(networkRequestCoordinator: requestCoordinator).fetchGifs(nextPageState: lastFetchedGifs.nextPageState, searchKey: gifSearchBar?.text) { [weak self] (result) in
                            DispatchQueue.main.async {
                                self?.isFetchingNextPage = false
                                switch result{
                                case .Success(result: let result):
                                    self?.handleFetchedGifsResult(lastFetchedGifs: result)
                                case .SuccessWithNoResponseData:
                                    fallthrough
                                case .Failure(error: _):
                                    print("<<<<<<<<<< error in fetching next page")
                                }
                            }
                        }
                    }
                case .EndOfLIst:
                    print("<<<<<<<<<<<<< has reached end")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let rawGifItem = frc?.object(at: IndexPath(item: indexPath.item, section: 0)).getRawObject() as? RawGif{
            dismiss(animated: true) {[weak self] in
                self?.feedsGIFSelectorDelegate?.finishedSelectingGif(rawGifItem)
            }
        }
    }
}

extension FeedsGIFSelectorViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let insets = collectionView.contentInset
        let width = (collectionView.bounds.width - insets.left - insets.right - 10)/2
        return CGSize(width: width, height: width)
    }
}

extension FeedsGIFSelectorViewController : NSFetchedResultsControllerDelegate{
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
           
       }
       public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
           
           if type == NSFetchedResultsChangeType.insert {
               print("Insert Object: \(newIndexPath)")
               if (gifCollection?.numberOfSections)! > 0 {
                   if gifCollection?.numberOfItems( inSection: newIndexPath!.section ) == 0 {
                       self.shouldReloadCollectionView = true
                   } else {
                       blockOperations.append(
                           BlockOperation(block: { [weak self] in
                               if let this = self {
                                   this.gifCollection?.insertItems(at: [newIndexPath!])
                               }
                           })
                       )
                   }
               } else {
                   self.shouldReloadCollectionView = true
               }
           }
           else if type == NSFetchedResultsChangeType.update {
               print("Update Object: \(indexPath) to \(newIndexPath)")
               blockOperations.append(
                   BlockOperation(block: { [weak self] in
                       if let this = self {
                           this.gifCollection?.reloadItems(at: [indexPath!])
                       }
                   })
               )
           }
           else if type == NSFetchedResultsChangeType.move {
               print("Move Object: \(indexPath) to \(newIndexPath)")
               blockOperations.append(
                   BlockOperation(block: { [weak self] in
                       if let this = self {
                           this.gifCollection?.deleteItems(at: [indexPath!])
                           this.gifCollection?.insertItems(at: [newIndexPath!])
                       }
                   })
               )
           }
           else if type == NSFetchedResultsChangeType.delete {
               print("Delete Object: \(indexPath)")
               if gifCollection?.numberOfItems( inSection: indexPath!.section ) == 1 {
                   self.shouldReloadCollectionView = true
               } else {
                   blockOperations.append(
                       BlockOperation(block: { [weak self] in
                           if let this = self {
                               this.gifCollection!.deleteItems(at: [indexPath!])
                           }
                       })
                   )
               }
           }
       }
       
       public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
           if (self.shouldReloadCollectionView) {
               print("reload data")
               self.gifCollection?.reloadData();
           } else {
               self.gifCollection!.performBatchUpdates({ () -> Void in
                   for operation: BlockOperation in self.blockOperations {
                       operation.start()
                   }
                   UIView.setAnimationsEnabled(false)
               }, completion: { (finished) -> Void in
                   self.blockOperations.removeAll(keepingCapacity: false)
                   UIView.setAnimationsEnabled(true)
               })
           }
       }
}
