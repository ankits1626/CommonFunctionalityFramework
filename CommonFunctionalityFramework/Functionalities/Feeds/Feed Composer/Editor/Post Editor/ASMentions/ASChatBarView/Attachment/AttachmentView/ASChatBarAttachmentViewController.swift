//
//  ASChatBarAttachmentViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

class ASChatBarAttachmentViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    weak var attachmentDataManager : AttachmentDataManager?
    weak var parentContainerHeightConstraint : NSLayoutConstraint?
    weak var delegate: AttachmentHandlerDelegate?
    
    @IBOutlet private weak var collectionView : UICollectionView?{
        didSet{
            if collectionView == nil{
                print("<<<<<<<<< **** collection deinitialized")
            }
            
        }
    }
    private lazy var localMediaManager: LocalMediaManager = {
        return LocalMediaManager()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    deinit {
        print("<<<<<<<<< **** deinitialized")
    }
    
    func updateHeight(){
        if let height = attachmentDataManager?.getRequiredAttachmentHeight(){
            parentContainerHeightConstraint?.constant = CGFloat(height)
        }else{
            parentContainerHeightConstraint?.constant = 0
        }
        self.view.frame = self.view.superview!.bounds
        DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.1) {
                self.collectionView?.reloadData()
            }
        
    }
    
    private func setup(){
        collectionView?.register(
            UINib(nibName: "MediaItemCollectionViewCell", bundle: Bundle(for: MediaItemCollectionViewCell.self)),
            forCellWithReuseIdentifier: "MediaItemCollectionViewCell"
        )
        collectionView?.register(
            UINib(nibName: "ComentAttachedDocumentCollectionViewCell", bundle: Bundle(for: ComentAttachedDocumentCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ComentAttachedDocumentCollectionViewCell"
        )
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
    
}

extension ASChatBarAttachmentViewController : UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = attachmentDataManager?.getNumberOfAttachments() ?? 0
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch attachmentDataManager!.getCurrentAttachmentType(){
        
        case .Image:
            fallthrough
            
        case .Video:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaItemCollectionViewCell",
            for: indexPath) as! MediaItemCollectionViewCell
            configureAttachedImageCell(cell, index: indexPath.item)
            return cell
        case .Document:
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "ComentAttachedDocumentCollectionViewCell",
            for: indexPath) as! ComentAttachedDocumentCollectionViewCell
            configureAttachedDocumentCell(cell, index: indexPath.item)
            return cell
        }
    }
    
    
    private func configureAttachedImageCell(_ cell: MediaItemCollectionViewCell, index: Int){
//        let attachmentImage = attachmentDataManager!.getAttachedImage(index: index)
        cell.removeButton?.isHidden = false
        cell.editTransparentView?.isHidden = false
        cell.curvedCornerControl()
        cell.removeButton?.handleControlEvent(
            event: .touchUpInside,
            buttonActionBlock: {[weak self] in
                self?.attachmentDataManager?.deleteSelectedImage(index, completion: {
                    self?.updateHeight()
                    self?.delegate?.finishedDeletingDocument()
                })
            }
        )
        loadLocalImage(index: index, imageView: cell.mediaCoverImageView)
        cell.mediaCoverImageView?.curvedCornerControl()
    }
    
    private func loadLocalImage(index : Int, imageView: UIImageView?){
        if let mediaItem = attachmentDataManager?.getAttachedImage(index: index){
            if let croppedImage = mediaItem.croppedImage{
                imageView?.image = croppedImage
                imageView?.contentMode = .scaleAspectFit
            }else if let asset = mediaItem.asset{
                localMediaManager.fetchImageForAsset(asset: asset, size: (imageView?.bounds.size)!, completion: { (_, fetchedImage) in
                    imageView?.image = fetchedImage
                })
            }
        }
    }
    
    private func configureAttachedDocumentCell(_ cell: ComentAttachedDocumentCollectionViewCell, index: Int){
        let attachment = attachmentDataManager!.getAttachedDocument(index: index)
        cell.documentNameLbl?.text = attachment.getFileName()
        cell.documentNameLbl?.font = .Medium11
        cell.documentNameLbl?.textColor = .black35
        cell.deleteDocument?.isHidden = false
        cell.deleteDocument?.handleControlEvent(
            event: .touchUpInside,
            buttonActionBlock: {[weak self] in
                self?.attachmentDataManager?.deleteSelectedDocument(index, completion: {
                    self?.updateHeight()
                    self?.delegate?.finishedDeletingDocument()
                })
            }
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch attachmentDataManager!.getCurrentAttachmentType(){
            
        case .Image:
            fallthrough
        case .Video:
            return CGSize(width: 82, height: 76)
        case .Document:
            return CGSize(width: UIScreen.main.bounds.width, height: 44)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var edgeInset = UIEdgeInsets()
        switch attachmentDataManager!.getCurrentAttachmentType(){
            
        case .Image:
            fallthrough
        case .Video:
            edgeInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        case .Document:
            edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return edgeInset
    }
}
