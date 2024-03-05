//
//  GroupBottomSheet.swift
//  SKOR
//
//  Created by Suyesh Kandpal on 02/01/24.
//  Copyright © 2024 Rewradz Private Limited. All rights reserved.
//

import UIKit
import SDWebImage

class GroupBottomSheet: UIViewController {

    @IBOutlet weak var infoDescription: UILabel!
    @IBOutlet weak var infoTitle: UILabel!
    @IBOutlet weak var infoImg: UIImageView!
    @IBOutlet weak var blurImg: UIImageView!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var okayBtn: UIButton!
    @IBOutlet weak var dismissLabel : UILabel!
    var categoryImage : String?
    var categoryName : String = ""
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        infoDescription.text = "With the 'As a Group' nomination feature, you can now nominate multiple candidates together. No more individual approvals – streamline the process and get your group of nominees approved in one go!".localized
        infoTitle.text = "As a Group Nomination".localized
        okayBtn.setTitle("Continue".localized, for: .normal)
        blurImg.makeBlurImage(targetImageView: blurImg)
        self.okayBtn.backgroundColor = UIColor.getControlColor()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        dismissLabel?.isUserInteractionEnabled = true
        dismissLabel?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setUpData() {
        loadUI(nominationImage: categoryImage, nominationCategoryName: categoryName)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        holderView.roundCorners(corners: [.topLeft,.topRight], radius: 12)
    }
    
    func loadUI(nominationImage : String?, nominationCategoryName : String) {
        if let unwrappedImage = nominationImage,
           !unwrappedImage.isEmpty{
            infoImg?.sd_setImage(
                with: URL(string: serverUrl+unwrappedImage),
                placeholderImage: nil,
                options: SDWebImageOptions.refreshCached,
                completed: nil
            )
        }else{
            infoImg?.image = UIImage(named: "UserLogo")
        }
        infoTitle.text = nominationCategoryName
        infoDescription.text = "With the 'As a Group' nomination feature, you can now nominate multiple candidates together. No more individual approvals – streamline the process and get your group of nominees approved in one go!".localized
    }
    
    @IBAction func okayPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
}
