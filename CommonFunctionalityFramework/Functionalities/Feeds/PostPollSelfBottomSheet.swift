//
//  PostPollSelfBottomSheet.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 16/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

enum Click3DotsByMeFilterType: String{
    case Edit = "Edit"
    case Pin = "Pin"
    case Delete = "Delete"
    case ReportAbuse = "ReportAbuse"
}

protocol Click3DotsByMeFilterTypeProtocol {
    func selectedFilterType(selectedType : Click3DotsByMeFilterType, feedIdentifier : Int64, isPostAlreadyPinned : Bool)
}
class PostPollSelfBottomSheet: UIViewController {
    
    @IBOutlet private weak var editButton : UIButton?
    @IBOutlet private weak var pinButton : UIButton?
    @IBOutlet private weak var deleteButton : UIButton?
    @IBOutlet private weak var reportButton : UIButton?
    
    
    @IBOutlet private weak var editButtonView : UIView?
    @IBOutlet private weak var pinButtonView : UIView?
    @IBOutlet private weak var deleteButtonView : UIView?
    @IBOutlet private weak var reportButtonView : UIView?
    
    var isPostAlreadyPinned : Bool = false
    var feedIdentifier : Int64 = 0
    
    
    
    var isEditEnabled : Bool = false
    var isDeleteEnabled : Bool = false
    var isreportAbusedEnabled : Bool = false
    var isPintoPostEnabled : Bool = false
    var numberofElementsEnabled : Int = 0
    
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var bottomsheetdelegate : Click3DotsByMeFilterTypeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        pinButtonView?.isHidden = isPintoPostEnabled == true ? false : true
        editButtonView?.isHidden = isEditEnabled == true ? false : true
        deleteButtonView?.isHidden = isDeleteEnabled == true ? false : true
        reportButtonView?.isHidden = isreportAbusedEnabled == true ? false : true
    }
    
    
    private func setup() {
        view.clipsToBounds = true    
        setupButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
    }
    
    
    private func setupButtons(){
        if isPostAlreadyPinned {
            pinButton?.setTitle("Unpin poll".localized, for: .normal)
        }else{
            pinButton?.setTitle("Pin poll".localized, for: .normal)
        }
    }
    
    
    
    func presentDrawer(numberofElementsEnabled : CGFloat) throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: numberofElementsEnabled < 3 ? 129 : 258.0)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw NSError(
                domain: "com.rewardz.ReceiptsComposer",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
            )
        }
    }
}
extension PostPollSelfBottomSheet{
    
    @IBAction func editButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .Edit, feedIdentifier: self.feedIdentifier, isPostAlreadyPinned: self.isPostAlreadyPinned)
        }
    }
    
    
    @IBAction func pinButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .Pin, feedIdentifier: self.feedIdentifier,isPostAlreadyPinned: self.isPostAlreadyPinned)
        }
    }
    
    @IBAction func deleteButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .Delete,feedIdentifier: self.feedIdentifier,isPostAlreadyPinned: self.isPostAlreadyPinned)
        }
    }
    
    @IBAction func reportButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .ReportAbuse,feedIdentifier: self.feedIdentifier,isPostAlreadyPinned: self.isPostAlreadyPinned)
        }
    }
}



