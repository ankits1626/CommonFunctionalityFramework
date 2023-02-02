//
//  BOUSApprovalPrivacyViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 25/08/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit

protocol ApprovalSelectedPrivacyType {
    func postVisibility(selectedPrivacyPK : Int, selectedVisibilityName : String, selectedVisibilityIcon : String)
}

class BOUSApprovalPrivacyViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var blurImg: UIImageView!
    var delegate : ApprovalSelectedPrivacyType?
    var privacyType = ["Public","Team", "Private"]
    var privacyDescription = ["Display on recognition feed for all to celebrate","Display only to colleagues of this recipient who share the same manager", "Do not display on recognition feed"]
    var privacyImage = ["icon_public","icon_mydepartment","icon_private"]
    var privacyPk = [20,10,30]
    var selectedPrivacyPK : Int = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImg.isUserInteractionEnabled = true
        blurImg.addGestureRecognizer(tapGestureRecognizer)
        self.holderView.layer.cornerRadius = 8.0
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! BOUSApprovalPrivacyTableViewCell
        cell.leftTitle.text = privacyType[indexPath.row]
        cell.leftDesc.text = privacyDescription[indexPath.row]
        cell.tickImg.isHidden = selectedPrivacyPK == privacyPk[indexPath.row] ? false : true
        cell.tickImg.image = UIImage(named: "interface_tick-circle")
        cell.tickImg.setImageColor(color: UIColor.getControlColor())
        cell.leftImg.image = UIImage(named: privacyImage[indexPath.row])
        if selectedPrivacyPK == privacyPk[indexPath.row] {
            cell.holderView.layer.borderColor = UIColor.getControlColor().cgColor
            cell.holderView.backgroundColor = #colorLiteral(red: 0.9602764249, green: 0.9721366763, blue: 1, alpha: 1)
            cell.holderView.layer.borderWidth = 1.0
            cell.holderView.layer.cornerRadius = 5.0
        }else {
            cell.holderView.layer.borderColor = #colorLiteral(red: 0.9288155437, green: 0.9402212501, blue: 0.998262465, alpha: 1)
            cell.holderView.backgroundColor = .white
            cell.holderView.layer.borderWidth = 1.0
            cell.holderView.layer.cornerRadius = 5.0
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(privacyPk[indexPath.row])
        selectedPrivacyPK = privacyPk[indexPath.row]
        delegate?.postVisibility(selectedPrivacyPK: selectedPrivacyPK,
                                 selectedVisibilityName: privacyType[indexPath.row],
                                 selectedVisibilityIcon: privacyImage[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
