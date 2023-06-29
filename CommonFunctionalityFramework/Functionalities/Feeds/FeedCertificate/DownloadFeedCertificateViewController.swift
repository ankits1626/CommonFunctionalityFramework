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
    func didFinishSavingCertificate(didSave: Bool)
}

class DownloadFeedCertificateViewController: UIViewController {
    
    @IBOutlet weak var imageHolderView: UIView!
    @IBOutlet weak var imagesHolderView: UIView!
    @IBOutlet weak var selectPictureLbl: UILabel!
    @IBOutlet weak var jpgImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadAsLbl: UILabel!
    @IBOutlet weak var jpgLbl: UILabel!
    @IBOutlet weak var pdfLbl: UILabel!
    @IBOutlet weak var imageListHolderView: NSLayoutConstraint!
    @IBOutlet weak var pdfImg: UIImageView!
    @IBOutlet weak var impLbl: UILabel!
    @IBOutlet weak var warningLbl: UILabel!
    @IBOutlet weak var collectionViewHolderHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomHolderView: UIView!
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    @IBOutlet weak var pdfBtn: UIButton!
    @IBOutlet weak var jpgBtn: UIButton!
    var targetFeed : FeedsItemProtocol?
    weak var themeManager: CFFThemeManagerProtocol?
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    let margin: CGFloat = 10
    var bottomViewHeight = 620.0
    var selectedIndex : Int!
    var delegate: CompletedCertificatedDownload?
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var is_download_choice_needed : Bool = false
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Setting up UI on viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    //Setting up collectionview if image count is more than 2 else hidden
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
        if is_download_choice_needed {
            if let mediaList = targetFeed?.getMediaList() {
                if mediaList.count == 0 {
                    self.imageHolderView.isHidden = true
                }else if mediaList.count > 3 {
                    self.imageHolderView.isHidden = false
                    self.collectionViewHolderHeight.constant = 300
                }else {
                    if mediaList.count == 1 {
                        self.selectedIndex = 0
                    }
                    self.imageHolderView.isHidden = false
                    self.collectionViewHolderHeight.constant = 150
                }
            }else {
                setUpCollectionViewForGifIfPresent()
            }
        } else {
            setUpCollectionViewForGifIfPresent()
        }
        
        pdfImg.setImageColor(color: UIColor.getControlColor())
        jpgImg.setImageColor(color: UIColor.getControlColor())
    }
    
    //Checking if gif is available
    func setUpCollectionViewForGifIfPresent() {
        if let giphy = targetFeed?.getGiphy(), !giphy.isEmpty {
            self.selectedIndex = 0
        }
        self.imageHolderView.isHidden = true
        self.bottomHolderView.isHidden = true
        self.bottomViewHeightConstraint.constant = 0
    }
    
    //Preenting drawer and setting height based on image count
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            if is_download_choice_needed {
                if let mediaList = targetFeed?.getMediaList() {
                    if mediaList.count == 0 {
                        slideInTransitioningDelegate.direction = .bottom(height: 340)
                    }else if mediaList.count > 3 {
                        slideInTransitioningDelegate.direction = .bottom(height: bottomViewHeight)
                    }else {
                        slideInTransitioningDelegate.direction = .bottom(height: 500)
                    }
                }else {
                    setUpViewHeightForGif()
                }
            }else {
                setUpViewHeightForGif()
            }
            
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedCertificateDrawerError.UnableToGetTopViewController
        }
    }
    
    //Heigt for gif view
    func setUpViewHeightForGif() {
        slideInTransitioningDelegate.direction = .bottom(height: 280)
    }
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
    }
    
    //Action for jpg button
    @IBAction func jpgPressed(_ sender: Any) {
        self.pdfBtn.isUserInteractionEnabled = false
        createUrlBasedOnImage(fileType: "image")
    }
    
    //Action for pdf button
    @IBAction func pdfPressed(_ sender: Any) {
        self.jpgBtn.isUserInteractionEnabled = false
        createUrlBasedOnImage(fileType: "pdf")
    }
    
    //Creating url based on selection between pdf and image
    func createUrlBasedOnImage(fileType: String) {
        var completeURL = ""
        self.activityIndicator.startAnimating()
        if let feedId = targetFeed?.feedIdentifier  {
            if is_download_choice_needed {
                if let mediaList = targetFeed?.getMediaList() {
                    if mediaList.count == 0 {
                        completeURL =  "/finance/api/download_certificate/\(feedId)/?appreciation=1&format_type=\(fileType)"
                    }else {
                        if selectedIndex == nil {
                            let alertView = UIAlertController(title: title, message: "Please select image", preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "OK".localized, style: .cancel, handler: nil)
                            alertView.addAction(cancelAction)
                            self.present(alertView, animated: true)
                            return
                        }
                        if let ecardPk = mediaList[selectedIndex].getImagePK() {
                            completeURL =  "finance/api/download_certificate/\(feedId)/?appreciation=1&attachment_type=ecard&attachment_id=\(ecardPk)&format_type=\(fileType)"
                        }else {
                            let imagePk = mediaList[selectedIndex].getRemoteId()
                            completeURL =  "finance/api/download_certificate/\(feedId)/?appreciation=1&attachment_type=image&attachment_id=\(imagePk)&format_type=\(fileType)"
                        }
                    }
                }else {
                    completeURL = checkForGifOrNotReturnUrl(feedId: feedId, fileType: fileType)
                }
            }else {
                completeURL = checkForGifOrNotReturnUrl(feedId: feedId, fileType: fileType)
            }
            fetchUrlToDownloadCertificate(url: completeURL)
        }
    }
    
    //Creating url if gif is available or not
    func checkForGifOrNotReturnUrl(feedId: Int64, fileType: String) -> String {
        var completeURL = ""
        if let giphy = targetFeed?.getGiphy(), !giphy.isEmpty {
            completeURL = "/finance/api/download_certificate/\(feedId)/?appreciation=1&format_type=image"
            return completeURL
        }else {
            completeURL = "/finance/api/download_certificate/\(feedId)/?appreciation=1&format_type=\(fileType)"
            return completeURL
        }
    }
    
    //Generating certificate image from the generated url
    func fetchUrlToDownloadCertificate(url: String) {
        feedCertificateDownload(networkRequestCoordinator: requestCoordinator).downloadFeddCertificate(url: url) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(result: let response):
                    if let imageUrl = response["url"] as? String {
                        self.collectionView.isUserInteractionEnabled = false
                        self.saveCertificate(fetchedImageUrl: imageUrl)
                    }else {
                        self.activityIndicator.stopAnimating()
                    }
                case .Failure(let error):
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), message: error.displayableErrorMessage())
                case .SuccessWithNoResponseData:
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("UNEXPECTED RESPONSE", comment: ""))
                }
            }
        }
    }
    
    //Using the generated url to download certificate
    func saveCertificate(fetchedImageUrl: String) {
        let url = URL(string: fetchedImageUrl)
        let fileName = String((randomString(length: 4) + "-" + url!.lastPathComponent)) as NSString
        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        URLSession.shared.downloadTask(with: url!, completionHandler: { (tempLocalUrl, response, error) -> Void in
            guard let tempLocalUrl = tempLocalUrl, error == nil else {
                self.activityIndicator.stopAnimating()
                return
            }
            do {
                try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                do {
                    //Show UIActivityViewController to save the downloaded file
                    let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    for indexx in 0..<contents.count {
                        if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                                self.jpgBtn.isUserInteractionEnabled = true
                                self.pdfBtn.isUserInteractionEnabled = true
                                let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                                if #available(iOS 15.4, *) {
                                    activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter, .postToWeibo, .mail, .print, .copyToPasteboard, .assignToContact, .addToReadingList, .postToFlickr, .postToVimeo, .postToTencentWeibo, .airDrop, .openInIBooks, .markupAsPDF, .sharePlay, .saveToCameraRoll]
                                }
                                activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                                    if !completed {
                                        self.delegate?.didFinishSavingCertificate(didSave: false)
                                    }
                                    
                                    if activityType == .saveToCameraRoll || activityType?.rawValue == "com.apple.DocumentManagerUICore.SaveToFiles" && error == nil {
                                        // User completed activity
                                        self.delegate?.didFinishSavingCertificate(didSave: true)
                                    }else {
                                        self.delegate?.didFinishSavingCertificate(didSave: false)
                                    }
                                    self.dismiss(animated: true)
                                }
                                self.present(activityViewController, animated: true, completion: nil)
                            }
                        }
                    }
                }
                catch ( _) {
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.showAlert(title: "", message: "Something went wrong. Try again later!") {_ in
                            self.dismiss(animated: true)
                        }
                    }
                }
            } catch ( _) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showAlert(title: "", message: "File already exists!") {_ in
                        self.dismiss(animated: true)
                    }
                }
            }
        }).resume()
    }
    
    //Random string to append with filename
    private func randomString(length: Int) -> String {
        let numbers : NSString = "0123"
        let len = UInt32(numbers.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = numbers.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
}

extension DownloadFeedCertificateViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //Number of rows in collection view
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
        if let giphy = targetFeed?.getGiphy(), !giphy.isEmpty {
            mediaFetcher.fetchImageAndLoad(cell.imageHolder, imageWithCompleteURL: giphy)
        }else {
            if let mediaList = targetFeed?.getMediaList() {
                let mediaItemUrl = mediaList[indexPath.row].getCoverImageUrl()
                mediaFetcher.fetchImageAndLoad(cell.imageHolder, imageEndPoint: mediaItemUrl ?? "")
                cell.tickImg.setImageColor(color: UIColor.white)
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
