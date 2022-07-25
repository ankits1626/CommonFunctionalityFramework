//
//  BOUSApproveAndRejectNominationViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

class BOUSApproveAndRejectNominationViewController: UIViewController {
    @IBOutlet weak var blurImg: UIImageView!
    @IBOutlet weak var nominationType: UILabel!
    @IBOutlet weak var nominationDescription: UILabel!
    @IBOutlet weak var imageType: UIImageView!
    @IBOutlet weak var yesBtn: UIButton!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noBtn: UIButton!
    var approverText = ""
    var rejectedText = ""
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var postId : Int!
    var isNominationApproved = false
    @IBOutlet weak var holderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rejectText: UITextView!
    var multipleNomination = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImg.isUserInteractionEnabled = true
        blurImg.addGestureRecognizer(tapGestureRecognizer)
        if isNominationApproved {
            self.nominationType.text = "Approve"
            holderViewHeightConstraint.constant = 400
            textViewHeightConstraint.constant = 0
            self.nominationDescription.text = "Are you sure you want to approve this nomination?"
        }else {
            self.nominationType.text = "Reject"
            self.imageType.image = UIImage(named: "cff_tick1")
            self.nominationDescription.text = "Are you sure you want to reject this nomination?"
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func yesPressed(_ sender: Any) {
        postToServer(approvalStatus: isNominationApproved)
    }
    
    @IBAction func noPressed(_ sender: Any) {
        postToServer(approvalStatus: false)
    }
    
    func postToServer(approvalStatus: Bool) {
        BOUSNominationAppoveRejectWorker(networkRequestCoordinator: self.requestCoordinator).postnomination(postId: postId, multipleNominations: multipleNomination, message: "", approvalStatus: approvalStatus) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .Success(_):
                    self.dismiss(animated: true)
                case .SuccessWithNoResponseData:
                    fallthrough
                case .Failure(_):
                    ErrorDisplayer.showError(errorMsg: "Failed to post, please try again.".localized) { (_) in}
                }
            }
        }
    }
}
