//
//  AttachmentHandler.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 04/10/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit

public protocol AttachmentHandlerDelegate : AnyObject{
    func finishedSelectionfFile(documentUrl: URL)
}

public class AttachmentHandler : NSObject{
    private weak var presentedViewController: UIViewController?
    public  weak var delegate: AttachmentHandlerDelegate?
    
    public override init() {
        super.init()
    }
    
    func showAttachmentOptions(){
        let drawer = AvailableAttachmentOptionsDrawerViewController(
            nibName: "AvailableAttachmentOptionsDrawerViewController",
            bundle: Bundle(for: AvailableAttachmentOptionsDrawerViewController.self)
        )
        do{
            try drawer.presentDrawer()
            drawer.attachPhotosButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {[weak self] in
                drawer.dismiss(animated: true) {
//                    self?.intiateImageAttachment()
                }
            })
            drawer.attachDocumentButton?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {[weak self] in
                drawer.dismiss(animated: true) {
                    self?.intiateDocumentAttachment()
                }
            })
        }catch let error{
            print("show error")
            ErrorDisplayer.showError(errorMsg: error.localizedDescription) { (_) in
            }
        }
    }
    
    private func intiateDocumentAttachment(){
        let importMenu = UIDocumentPickerViewController(documentTypes: ["public.text", "com.apple.iwork.pages.pages", "public.data","kUTTypePDF"], in: UIDocumentPickerMode.import)
        importMenu.delegate = self
        if let topviewController : UIViewController = UIApplication.topViewController(){
            topviewController.present(importMenu, animated: true, completion: nil)
            presentedViewController = importMenu
        }else{
            //throw FeedsComposerDrawerError.UnableToGetTopViewController
        }
    }
    
    
}

extension AttachmentHandler : UIDocumentPickerDelegate {
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        presentedViewController?.dismiss(animated: true)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.downloadDocumentfiles(documentUrl: url) { [weak self] (sucess, FinalUrl) in
            if sucess,
            let unwrappedFinalUrl = FinalUrl{
                DispatchQueue.main.async {
                    self?.delegate?.finishedSelectionfFile(documentUrl: unwrappedFinalUrl)
                    debugPrint("here")
                }
            }else{
                print("error")
            }
        }
        delegate?.finishedSelectionfFile(documentUrl: url)
    }
    
    private func downloadDocumentfiles(documentUrl : URL, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(documentUrl.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            debugPrint("The file already exists at path")
            completion(true, destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: documentUrl, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    print("File moved to documents folder")
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
}
