//
//  AssetGridViewController.swift
//  Cerrapoints SG
//
//  Created by Rewardz on 25/11/17.
//  Copyright © 2017 Rewradz Private Limited. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

class AssetGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var navigationColor: UIImageView!
    var fetchResult: PHFetchResult<PHAsset>!
    var assetCollection: PHAssetCollection!
    var assetSelectionCompletion : ((_ assets : [LocalSelectedMediaItem]?) -> Void)?
    var completion : ((_ images : [URL]?, _ error : Error?) -> Void)?
    @IBOutlet var uploadButton : UIButton!
    @IBOutlet var collectionView: UICollectionView!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate var selectedAssets = [LocalSelectedMediaItem]()
    fileprivate var cachedLocalAssets = [LocalSelectedMediaItem]()
    
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    private func setup(){
        uploadButton.setTitleColor(.black, for: .normal)
        self.navigationColor.image = UIImage(named: "")
        //self.navigationColor.backgroundColor = .getHeaderColor()
        resetCachedAssets()
        setupCollectionView()
        setupFetchresult()
    }
    
    private func setupFetchresult(){
        PHPhotoLibrary.shared().register(self)
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)// PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)
        }
    }
    
    private func setupCollectionView(){
        collectionView.register(UINib(nibName: "GridViewCell", bundle: Bundle(for: GridViewCell.self)), forCellWithReuseIdentifier: "GridViewCell")
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
       // self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func uploadButtonTapped(_ sender: AnyObject) {
        
        dismiss(animated: true) {
            if let unwrappedCompletion = self.assetSelectionCompletion{
                unwrappedCompletion(self.selectedAssets)
            }
        }
        return
//        var images = [UIImage]()
//        var videos = [AVAsset]()
//        let photoAsset = PHAsset.fetchAssets(withLocalIdentifiers: selectedAssets, options: nil)
//        let contentMode: PHImageContentMode = PHImageContentMode.aspectFit
//            // photoAsset is an object of type PHFetchResult
//        var processedAssets = 0
//        photoAsset.enumerateObjects ({ (object, index, stop) in
//            let options = PHImageRequestOptions()
//            options.isSynchronous = true
//            options.deliveryMode = .highQualityFormat
//            let videorequestOption = PHVideoRequestOptions()
//            //videorequestOption. = true
//            videorequestOption.deliveryMode = .highQualityFormat
//            if object.mediaType == .video{
//                PHImageManager.default().requestAVAsset(forVideo: object, options: videorequestOption) { (asset, audioMix, map) in
//                    processedAssets = processedAssets + 1
//                    if let unwrappedAsset = asset{
//                        videos.append(unwrappedAsset)
//                    }else{
//                        print("<<<<<<<<<< video asset not available")
//                    }
//                    if processedAssets == self.selectedAssets.count{
//                        self.handleSelectedVideos(selectdImages: videos)
//                        self.handleSelectedImages(selectdImages: images)
//                    }
//                }
//            }else{
//                PHImageManager.default().requestImage(for: object as PHAsset, targetSize: PHImageManagerMaximumSize, contentMode: contentMode, options: options) {
//                    image, info in
//                    processedAssets = processedAssets + 1
//                    images.append(image!)
//                    if processedAssets == self.selectedAssets.count{
//                        self.handleSelectedVideos(selectdImages: videos)
//                        self.handleSelectedImages(selectdImages: images)
//                    }
//                }
//            }
//
//        })
        
    
//        self.dismiss(animated: true) {
//            if let unwrappedCompletion = self.completion{
//                unwrappedCompletion(imageURLs, error)
//            }
//        }
        //self.navigationController?.popViewController(animated: true)
    }
    
     private func handleSelectedVideos(selectdImages : [AVAsset]){
        print("@@@@@@@@@@@@@@@@@@@@@@@ save videos")
    }
    
    private func handleSelectedImages(selectdImages : [UIImage]){
        print("@@@@@@@@@@@@@@@@@@@@@@@ save images")
        var imageURLs = [URL]()
        var error : Error?
        
        for anImage in selectdImages{
            let saveImageResult = self.saveImageToDocumentsDirectory(anImage)
            if let unwrappedURL = saveImageResult.imageURL{
                imageURLs.append(unwrappedURL)
            }
            if let unwrappedError = saveImageResult.error{
                error = unwrappedError
            }
        }
    }
    
    fileprivate func saveImageToDocumentsDirectory(_ sourceImage : UIImage) -> (imageURL:URL?, error:Error?){
        let directoryPath =  NSHomeDirectory().appending("/Documents/feedAttachedPostImages/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let filename = String(format: "%@.jpg",randomString(length: 10))
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try sourceImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            return (url, nil)
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return (nil , error)
        }
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }

    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItemSize()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     guard let destination = segue.destination as? AssetViewController
     else { fatalError("unexpected view controller for segue") }
     guard let cell = sender as? UICollectionViewCell else { fatalError("unexpected sender") }
     
     if let indexPath = collectionView?.indexPath(for: cell) {
     destination.asset = fetchResult.object(at: indexPath.item)
     }
     destination.assetCollection = assetCollection
     }*/
    
    private func updateItemSize() {
        
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    // MARK: UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let asset = fetchResult.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell",
                                                            for: indexPath) as? GridViewCell
            else { fatalError("unexpected cell in collection view") }
        
        
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        cell.playButton.isHidden = asset.mediaType != .video
        
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset.
            if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                cell.thumbnailImage = image
            }
        })
        cell.selectedIndicatorView.backgroundColor = UIColor(red: 0, green: 82/255.0, blue: 147/255.0, alpha: 0.8)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        uploadButton.isHidden = selectedAssets.count == 0
        let asset = fetchResult.object(at: indexPath.item)
        //asset.localIdentifier
        (cell as! GridViewCell).selectedIndicatorView.isHidden = !selectedAssets.contains(
            LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType))
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        toggleSelectionOfItem(indexpath: indexPath)
    }
    
    fileprivate func toggleSelectionOfItem(indexpath : IndexPath){
        let asset = fetchResult.object(at: indexpath.item)
        
        if selectedAssets.contains(LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType)){
            selectedAssets = selectedAssets.filter(){$0 != LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType)}
        }else{
            selectedAssets.append(LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType))
        }
        updateSelectionMarkerForItem(indexpath: indexpath)
    }
    
    fileprivate func updateSelectionMarkerForItem(indexpath : IndexPath){
        uploadButton.isHidden = selectedAssets.count == 0
        if let cell = collectionView.cellForItem(at: indexpath) as? GridViewCell{
            let asset = fetchResult.object(at: indexpath.item)
            cell.selectedIndicatorView.isHidden = !selectedAssets.contains(LocalSelectedMediaItem(identifier: asset.localIdentifier, mediaType: asset.mediaType))
        }else{
            print("$$$$$$$$$$$$$$$$$ no cell found")
        }
    }
    
    // MARK: UIScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    // MARK: Asset Caching
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    fileprivate func updateCachedAssets() {
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
    // MARK: UI Actions
    
    @IBAction func addAsset(_ sender: AnyObject?) {
        
        // Create a dummy image of a random solid color and random orientation.
        let size = (arc4random_uniform(2) == 0) ?
            CGSize(width: 400, height: 300) :
            CGSize(width: 300, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(hue: CGFloat(arc4random_uniform(100)) / 100,
                    saturation: 1, brightness: 1, alpha: 1).setFill()
            context.fill(context.format.bounds)
        }
        
        // Add it to the photo library.
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let assetCollection = self.assetCollection {
                let addAssetRequest = PHAssetCollectionChangeRequest(for: assetCollection)
                addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
            }
        }, completionHandler: {success, error in
            if !success { print("error creating asset: \(String(describing: error))") }
        })
    }
    
}

// MARK: PHPhotoLibraryChangeObserver
extension AssetGridViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        guard let changes = changeInstance.changeDetails(for: fetchResult)
            else { return }
        
        // Change notifications may be made on a background queue. Re-dispatch to the
        // main queue before acting on the change as we'll be updating the UI.
        DispatchQueue.main.sync {
            // Hang on to the new fetch result.
            fetchResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                // If we have incremental diffs, animate them in the collection view.
                guard let collectionView = self.collectionView else { fatalError() }
                collectionView.performBatchUpdates({
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, reload, move
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map({ IndexPath(item: $0, section: 0) }))
                    }
                    if let changed = changes.changedIndexes, !changed.isEmpty {
                        collectionView.reloadItems(at: changed.map({ IndexPath(item: $0, section: 0) }))
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                to: IndexPath(item: toIndex, section: 0))
                    }
                })
            } else {
                // Reload the collection view if incremental diffs are not available.
                collectionView!.reloadData()
            }
            resetCachedAssets()
        }
    }
}

protocol ImageSaverProtocol {
    func saveImageToDocumentsDirectory(_ sourceImage : UIImage) -> (imageURL:URL?, error:Error?)
}
extension ImageSaverProtocol{
    func saveImageToDocumentsDirectory(_ sourceImage : UIImage) -> (imageURL:URL?, error:Error?){
        let directoryPath =  NSHomeDirectory().appending("/Documents/Receipts/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        let filename = String(format: "%@.jpg",randomString(length: 10))
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try sourceImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            return (url, nil)
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return (nil , error)
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
}
