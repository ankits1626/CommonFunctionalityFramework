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
    @IBOutlet var uploadButton : UIButton!
    @IBOutlet var collectionView: UICollectionView!
    fileprivate var thumbnailSize: CGSize!
    var selectedAssets = [LocalSelectedMediaItem]()
    var localMediaManager : LocalMediaManager!
    var maximumItemSelectionAllowed = 10
    
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    
    private func setup(){
        uploadButton.setTitleColor(.black, for: .normal)
        self.navigationColor.image = UIImage(named: "")
        setupCollectionView()
        setupFetchresult()
        setupUploadButton()
    }
    
    private func setupUploadButton(){
        uploadButton.backgroundColor = .black
        uploadButton.curvedCornerControl()
        uploadButton.setTitleColor(.white, for: .normal)
        uploadButton.titleLabel?.font = .Button
    }
    
    private func setupFetchresult(){
        //PHPhotoLibrary.shared().register(self)
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)
            //PHAsset.fetchAssets(with: allPhotosOptions) // for images + videos
            // PHAsset.fetchAssets(with: PHAssetMediaType.image, options: allPhotosOptions)
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
    }
        
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
        localMediaManager.fetchImageForAsset(asset: asset, size: thumbnailSize) { (assetIdentifier, fetchedImage) in
            if cell.representedAssetIdentifier == assetIdentifier && fetchedImage != nil {
                cell.thumbnailImage = fetchedImage
            }
        }
        cell.selectedIndicatorView.backgroundColor = UIColor(red: 0, green: 82/255.0, blue: 147/255.0, alpha: 0.8)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        uploadButton.isHidden = selectedAssets.count == 0
        let asset = fetchResult.object(at: indexPath.item)
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
            if selectedAssets.count < maximumItemSelectionAllowed{
                selectedAssets.append(LocalSelectedMediaItem(identifier: asset.localIdentifier, asset: asset, mediaType: asset.mediaType))
            }else{
                ErrorDisplayer.showError(errorMsg: "Cannot select more than 10 images") { (_) in
                }
            }
            
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
    
}

