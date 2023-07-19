//
//  InpireMeErrorViewController.swift
//  SKOR
//
//  Created by Puneeeth on 01/02/23.
//  Copyright © 2023 Rewradz Private Limited. All rights reserved.
//

import UIKit

public class InpireMeErrorViewController: UIViewController {
    
    @IBOutlet private weak var blurImg: UIImageView!
    @IBOutlet private weak var holderView: UIView!
    @IBOutlet private weak var numberLbl1: UILabel?
    @IBOutlet private weak var numberLbl2: UILabel?
    @IBOutlet private weak var numberLbl3: UILabel?
    @IBOutlet private weak var numberLbl4: UILabel?
    @IBOutlet private weak var okBtn: UIButton?
    @IBOutlet private weak var forExText: UITextView?
    
    var forExTextMessage : String?
    public override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }

    func setUpUI() {
        self.numberLbl1?.backgroundColor = UIColor.getControlColor()
        self.numberLbl2?.backgroundColor = UIColor.getControlColor()
        self.numberLbl3?.backgroundColor = UIColor.getControlColor()
        self.numberLbl4?.backgroundColor = UIColor.getControlColor()
        self.okBtn?.backgroundColor = .getControlColor()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImg.isUserInteractionEnabled = true
        blurImg.addGestureRecognizer(tapGestureRecognizer)
        self.holderView.layer.cornerRadius = 8.0
        self.forExText?.attributedText = attributedText(
            text: forExTextMessage ??  "For example: Sheila, thanks for catching that accounting error. Because of that, we saved 10 hours of work recovering from a bad invoice.",
            toMediumFont: "For example"
        )
    }
    
    func attributedText(text: String, toMediumFont: String) -> NSAttributedString {
        let string = text as NSString
        let attributedString = NSMutableAttributedString(string: string as String, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14.0)])
        let mediumFontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: .medium)]
        attributedString.addAttributes(mediumFontAttribute, range: string.range(of: toMediumFont))
        return attributedString
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
