//
//  DeleteCommentDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 06/09/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

protocol DeleteCommentProtocol {
    func deleteCommentPressed(commentID : Int64)
}

class DeleteCommentDrawer: UIViewController {

    var delegate : DeleteCommentProtocol?
    @IBOutlet weak var holderVIew: UIView!
    @IBOutlet weak var viewConatinerView: UIView?
    @IBOutlet weak var commentImg: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var deleteAddress: UILabel!
    @IBOutlet weak var areYouSureLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    var commentId : Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton?.backgroundColor = UIColor.getControlColor()
        deleteAddress.text = "Delete Comment".localized
        areYouSureLabel.text = "Are you sure you want to delete this comment?".localized
        confirmButton.setTitle("Delete", for: .normal)
        cancelButton.setTitle("Cancel".localized, for: .normal)
        cancelButton.setTitleColor(UIColor.getControlColor(), for: .normal)
        commentImg.setImageColor(color: UIColor.getControlColor())
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        viewConatinerView?.isUserInteractionEnabled = true
        viewConatinerView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        holderVIew?.roundCorners(corners: [.topLeft,.topRight], radius: 16)
        confirmButton?.roundCorners(corners: .allCorners, radius: 8.0)
    }

    @IBAction func confirmButton(_ sender: Any) {
        delegate?.deleteCommentPressed(commentID: self.commentId)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
}


