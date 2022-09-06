//
//  EditCommentDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 05/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

enum EditCommentType: String{
    case Edit = "Edit"
    case Delete = "Delete"
}

protocol EditCommentTypeProtocol {
    func selectedFilterType(selectedType : EditCommentType, commentIdentifier : Int64, chatMessage : String)
}
class EditCommentDrawer: UIViewController {
    
    @IBOutlet private weak var editButton : UIButton?
    @IBOutlet private weak var deleteButton : UIButton?
    
    
    @IBOutlet private weak var editButtonView : UIView?
    @IBOutlet private weak var deleteButtonView : UIView?
    
    var commentFeedIdentifier : Int64 = 0
    var chatMessage : String = ""
    
    
    var isEditEnabled : Bool = false
    var isDeleteEnabled : Bool = false
    var numberofElementsEnabled : Int = 0
    
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var bottomsheetdelegate : EditCommentTypeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        editButtonView?.isHidden = isEditEnabled == true ? false : true
        deleteButtonView?.isHidden = isDeleteEnabled == true ? false : true
    }
    
    
    private func setup() {
        view.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
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
extension EditCommentDrawer{
    
    @IBAction func editButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .Edit, commentIdentifier: self.commentFeedIdentifier, chatMessage: self.chatMessage)
        }
    }
    
    
    
    @IBAction func deleteButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .Delete, commentIdentifier: self.commentFeedIdentifier, chatMessage: self.chatMessage)
        }
    }
    
}



