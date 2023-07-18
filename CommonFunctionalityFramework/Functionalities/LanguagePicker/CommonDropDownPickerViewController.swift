//
//  CommonDropDownPickerViewController.swift
//  SKOR
//
//  Created by Suyesh Kandpal on 14/07/22.
//  Copyright © 2022 Rewradz Private Limited. All rights reserved.
//

import UIKit
import RewardzCommonComponents

public protocol DropDownProtocol {
    func selectedValue(index : Int)
}

public protocol LanguageOptionProtocol{
    var slug: String {get}
    var title : String {get}
//    var type : FilterOptionType {get}
    var showcategory : Bool {get}
}


public class CommonDropDownPickerViewController: UIViewController {

    public var delegate : DropDownProtocol?
    @IBOutlet weak var holderVIew: UIView!
    @IBOutlet weak var viewConatinerView: UIView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dropDownTableView : UITableView?
    public var languageNames : [LanguageOptionProtocol] = []
    public var selectedSlug : String = ""
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        registerDropDownCell()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        viewConatinerView?.isUserInteractionEnabled = true
        viewConatinerView?.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func registerDropDownCell() {
        dropDownTableView?.register(
            UINib(nibName: "BousLanguageTableViewCell", bundle: Bundle(for: CommonDropDownPickerViewController.classForCoder())),
            forCellReuseIdentifier: "BousLanguageTableViewCell"
        )
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        holderVIew?.roundCorners(corners: [.topLeft,.topRight], radius: 16)
    }

    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
}
//MARK: UITableViewDelegate/UITableViewDatasource
extension CommonDropDownPickerViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageNames.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BousLanguageTableViewCell") as! BousLanguageTableViewCell
        let languages = self.languageNames[indexPath.row]
        cell.checkBox?.isChecked = languages.slug == self.selectedSlug ? true : false
        cell.titleLabel?.text = languages.title
//        get_backgroundColor()
        let borderColor = languages.slug == self.selectedSlug ? "#0066ff"  : "#EDF0FF"
        cell.languageconatiner?.curvedUIBorderedControl(
            borderColor: .getControlColor(), // Rgbconverter.HexToColor(borderColor),
            borderWidth: 1.0,
            cornerRadius: 8.0
        )
        cell.languageconatiner?.backgroundColor = languages.slug == self.selectedSlug ? Rgbconverter.HexToColor("#F5F8FF") : .white
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.selectedValue(index: indexPath.row)
        self.dismiss(animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
}

