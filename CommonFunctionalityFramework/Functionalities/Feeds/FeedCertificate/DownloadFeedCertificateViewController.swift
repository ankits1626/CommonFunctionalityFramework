//
//  DownloadFeedCertificateViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 01/04/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

class FeedCertificateDrawerError {
    static let UnableToGetTopViewController = NSError(
        domain: "com.commonfunctionality.FeedCertificateDrawerError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
    )
}

protocol CompletedCertificatedDownload {
    func didFinishSavingCertificate()
}

class DownloadFeedCertificateViewController: UIViewController {
    
    @IBOutlet weak var imageHolderView: UIView!
    @IBOutlet weak var imagesHolderView: UIView!
    @IBOutlet weak var jpgImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageListHolderView: NSLayoutConstraint!
    @IBOutlet weak var pdfImg: UIImageView!
    @IBOutlet weak var collectionViewHolderHeight: NSLayoutConstraint!
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var targetFeed : FeedsItemProtocol?
    weak var themeManager: CFFThemeManagerProtocol?
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    let margin: CGFloat = 10
    var bottomViewHeight = 620.0
    var selectedIndex : Int!
    var delegate: CompletedCertificatedDownload?
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    private func setupCollectionView(){
        collectionView?.register(
            UINib(nibName: "MediaForCertificateDownloadCollectionViewCell", bundle: Bundle(for: MediaForCertificateDownloadCollectionViewCell.self)),
            forCellWithReuseIdentifier: "MediaForCertificateDownloadCollectionViewCell"
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        if let mediaList = targetFeed?.getMediaList() {
            if mediaList.count == 0 {
                self.imageHolderView.isHidden = true
            }else if mediaList.count > 3 {
                self.collectionViewHolderHeight.constant = 300
            }else {
                if mediaList.count == 1 {
                    self.selectedIndex = 0
                }
                self.collectionViewHolderHeight.constant = 150
            }
        }else {
            if let giphy = targetFeed?.getGiphy() {
                self.selectedIndex = 0
                self.imageHolderView.isHidden = false
            }else {
                self.imageHolderView.isHidden = true
            }
        }
        pdfImg.setImageColor(color: UIColor.getControlColor())
        jpgImg.setImageColor(color: UIColor.getControlColor())
    }
    
    @IBAction func jpgPressed(_ sender: Any) {
        createUrlBasedOnImage(fileType: "image")
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            if let mediaList = targetFeed?.getMediaList() {
                if mediaList.count == 0 {
                    slideInTransitioningDelegate.direction = .bottom(height: 340)
                }else if mediaList.count > 3 {
                    slideInTransitioningDelegate.direction = .bottom(height: bottomViewHeight)
                }else {
                    slideInTransitioningDelegate.direction = .bottom(height: 500)
                }
            }else {
                if let giphy = targetFeed?.getGiphy() {
                    slideInTransitioningDelegate.direction = .bottom(height: 500)
                }else {
                    slideInTransitioningDelegate.direction = .bottom(height: 340)
                }
            }
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedCertificateDrawerError.UnableToGetTopViewController
        }
    }
    
    func createUrlBasedOnImage(fileType: String) {
        var completeURL = ""
        if let baseUrl = requestCoordinator.getBaseUrlProvider().baseURLString(), let feedId = targetFeed?.feedIdentifier  {
            if let mediaList = targetFeed?.getMediaList() {
                if mediaList.count == 0 {
                    completeURL = (baseUrl) + "/finance/api/download_certificate/\(feedId)/?appreciation=1&format_type=\(fileType)"
                    saveCertificate(urlString: completeURL)
                }else {
                    if selectedIndex == nil {
                        let alertView = UIAlertController(title: title, message: "Please select image", preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "OK".localized, style: .cancel, handler: nil)
                        alertView.addAction(cancelAction)
                        self.present(alertView, animated: true)
                        return
                    }
                    if let ecardPk = mediaList[selectedIndex].getImagePK() {
                        completeURL = (baseUrl) + "finance/api/download_certificate/\(feedId)/?appreciation=1&attachment_type=ecard&attachment_id=\(ecardPk)&format_type=\(fileType)"
                        saveCertificate(urlString: completeURL)
                    }else {
                        let imagePk = mediaList[selectedIndex].getRemoteId()
                        completeURL = (baseUrl) + "finance/api/download_certificate/\(feedId)/?appreciation=1&attachment_type=image&attachment_id=\(imagePk)&format_type=\(fileType)"
                        saveCertificate(urlString: completeURL)
                    }
                }
            }else {
                if let giphy = targetFeed?.getGiphy() {
                    completeURL = (baseUrl) + "/finance/api/download_certificate/\(feedId)/?appreciation=1&format_type=gif"
                    saveCertificate(urlString: completeURL)
                }else {
                    completeURL = (baseUrl) + "/finance/api/download_certificate/\(feedId)/?appreciation=1&format_type=\(fileType)"
                    saveCertificate(urlString: completeURL)
                }
            }
        }
    }
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    @IBAction func pdfPressed(_ sender: Any) {
        createUrlBasedOnImage(fileType: "pdf")
    }
    
    func saveCertificate(urlString: String) {
        let url = URL(string: urlString)
        let fileName = String((url!.lastPathComponent)) as NSString
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent(String(format: "%@\(fileName)",randomString(length: 10)))
        let fileURL = URL(string: urlString)
        URLSession.shared.downloadTask(with: fileURL!, completionHandler: { (tempLocalUrl, response, error) -> Void in
            guard let tempLocalUrl = tempLocalUrl, error == nil else { return }
            do {
                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                do {
                    //Show UIActivityViewController to save the downloaded file
                    let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for indexx in 0..<contents.count {
                        if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                            DispatchQueue.main.async {
                                let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                                    if !completed {
                                        // User canceled
                                        return
                                    }
                                    // User completed activity
                                    self.delegate?.didFinishSavingCertificate()
                                    self.dismiss(animated: true)
                                }
                                self.present(activityViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
                catch (let err) {
                    print("error: \(err)")
                }
            } catch (let writeError) {
                print("Error creating a file \(destinationFileUrl) : \(writeError)")
            }
        }).resume()
    }
    
    private func randomString(length: Int) -> String {
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

extension DownloadFeedCertificateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let mediaList = targetFeed?.getMediaList() {
            return mediaList.count
        }
        if let _ = targetFeed?.getGiphy() {
            return 1
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MediaForCertificateDownloadCollectionViewCell",
            for: indexPath) as? MediaForCertificateDownloadCollectionViewCell
        else { fatalError("unexpected cell in collection view")
        }
        if let giphy = targetFeed?.getGiphy() {
            mediaFetcher.fetchImageAndLoad(cell.imageHolder, imageWithCompleteURL: giphy)
        }else {
            if let mediaList = targetFeed?.getMediaList() {
                let mediaItemUrl = mediaList[indexPath.row].getCoverImageUrl()
                mediaFetcher.fetchImageAndLoad(cell.imageHolder, imageEndPoint: mediaItemUrl ?? "")
                cell.tickImg.setImageColor(color: UIColor.getControlColor())
                if mediaList.count > 1 {
                    if selectedIndex == indexPath.row {
                        cell.tickImg.isHidden = false
                        cell.selectedGrayImg.isHidden = false
                    }else {
                        cell.tickImg.isHidden = true
                        cell.selectedGrayImg.isHidden = true
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.collectionView.reloadData()
    }
    
}

extension DownloadFeedCertificateViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 3   //number of column you want
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
        + flowLayout.sectionInset.right
        + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: size, height: 112)
    }
}
