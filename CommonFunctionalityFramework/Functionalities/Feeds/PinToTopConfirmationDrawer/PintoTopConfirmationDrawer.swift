//
//  PintoTopConfirmationDrawer.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 12/04/21.
//  Copyright © 2021 Rewardz. All rights reserved.
//

import UIKit

class PintoTopConfirmationDrawer: UIViewController {
    @IBOutlet private weak var closeLabel : UILabel?
    @IBOutlet private weak var titleLabel : UILabel?
    @IBOutlet private weak var messageLabel : UILabel?
    @IBOutlet private weak var confirmedButton : UIButton?
    @IBOutlet private weak var cancelButton : UIButton?
    @IBOutlet private weak var postFrequency : UIView?
    @IBOutlet private weak var frequencyView : UIView?
    weak var themeManager: CFFThemeManagerProtocol?
    @IBOutlet private weak var frequencyLabel : UILabel!
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var confirmedCompletion : ((_ selectedFrequency : Int) -> Void)?
    var targetFeed : FeedsItemProtocol?
    var isAlreadyPinned : Bool = false
    let dropDown = ItemsDropDown()
    var dropDownRowHeight: CGFloat = 40
    var frquencyModelArr: [PostPinDropDownValue] = [PostPinDropDownValue]()
    var selectedFrequencyValue : Int = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateFrequencyModelArray()
        setup()
        setUpGestures()
        postFrequency?.addBorders(edges: [.all], color: .gray)
    }
    
    private func populateFrequencyModelArray(){
        let frequency1 = PostPinDropDownValue(frequencyName: "1 day".localized, frequencyID: 1)
        let frequency2 = PostPinDropDownValue(frequencyName: "1 week".localized, frequencyID: 7)
        let frequency3 = PostPinDropDownValue(frequencyName: "1 month".localized, frequencyID: 30)
        let frequency4 = PostPinDropDownValue(frequencyName: "Always".localized, frequencyID: 0)
        self.frquencyModelArr.append(frequency1)
        self.frquencyModelArr.append(frequency2)
        self.frquencyModelArr.append(frequency3)
        self.frquencyModelArr.append(frequency4)
    }
    
    func setUpGestures(){
        self.frequencyLabel.isUserInteractionEnabled = true
        let labelTapGesture = UITapGestureRecognizer(target: self, action: #selector(frequencyLabelTapped))
        self.frequencyLabel.addGestureRecognizer(labelTapGesture)
    }
    
    @objc func frequencyLabelTapped(){
        self.dropDown.showDropDown(height: self.dropDownRowHeight * 4)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Call this in viewDidAppear to get correct frame values
        setUpDropDown()
    }
    
    func setUpDropDown(){
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: (CGRect(x: self.postFrequency!.frame.origin.x, y: self.postFrequency!.frame.origin.y - 40, width: self.postFrequency!.frame.width, height: self.postFrequency!.frame.height)), offset: 2)
        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: Bundle(for: DropDownTableViewCell.self))
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    private func setup(){
        view.clipsToBounds = true
        self.frequencyLabel.text = "1 week".localized
        view.roundCorners(corners: [.topLeft, .topRight], radius: AppliedCornerRadius.standardCornerRadius)
        closeLabel?.font = .Caption1
        if isAlreadyPinned {
            titleLabel?.text = "Unpin the post".localized
            frequencyView?.alpha = 0
            messageLabel?.text = "".localized
        }else{
            titleLabel?.text = "Pin this post to top".localized
            frequencyView?.alpha = 1
            messageLabel?.text = "".localized
        }
        titleLabel?.font = .Title1
        titleLabel?.font = .Title1
        messageLabel?.font = .Caption2
        configureConfirmButton()
        configureCancelButton()
    }
    
    private func configureConfirmButton(){
        confirmedButton?.setTitle("CONFIRM".localized, for: .normal)
        confirmedButton?.titleLabel?.font = .Button
        confirmedButton?.setTitleColor(.bottomAssertiveButtonTextColor, for: .normal)
        confirmedButton?.backgroundColor = themeManager?.getControlActiveColor() ?? .bottomAssertiveBackgroundColor
        if let unwrappedThemeManager = themeManager{
            confirmedButton?.curvedBorderedControl(borderColor: unwrappedThemeManager.getControlActiveColor(), borderWidth: 1.0)
        }else{
            confirmedButton?.curvedBorderedControl()
        }
    }
    
    private func configureCancelButton(){
        cancelButton?.setTitle("CANCEL".localized, for: .normal)
        cancelButton?.titleLabel?.font = .Button
        cancelButton?.setTitleColor(.bottomDestructiveButtonTextColor, for: .normal)
        cancelButton?.backgroundColor = .bottomDestructiveBackgroundColor
        if let controlColor = themeManager?.getControlActiveColor(){
            cancelButton?.curvedBorderedControl(borderColor: controlColor, borderWidth: 1.0)
            cancelButton?.setTitleColor(controlColor, for: .normal)
        }else{
            cancelButton?.curvedBorderedControl()
        }
    }
    
    func presentDrawer() throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: 360)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw FeedConfirmationDrawerError.UnableToGetTopViewController
        }
    }
    
    @IBAction private func closeDrawer(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func confirmedButtonPressed(){
        if let unwrappedCompletion = confirmedCompletion{
            dismiss(animated: true) {
                unwrappedCompletion(self.selectedFrequencyValue)
            }
        }
    }
}

struct PostPinDropDownValue {
    var frequencyName: String
    var frequencyID: Int
}

extension PintoTopConfirmationDrawer: MakeDropDownDataSourceProtocol{
    func getDataToDropDown(cell: UITableViewCell, indexPos: Int, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            let customCell = cell as! DropDownTableViewCell
            customCell.frequncyNameLabel.text = self.frquencyModelArr[indexPos].frequencyName
        }
    }
    
    func numberOfRows(makeDropDownIdentifier: String) -> Int {
        return self.frquencyModelArr.count
    }
    
    func selectItemInDropDown(indexPos: Int, makeDropDownIdentifier: String) {
        self.frequencyLabel.text = self.frquencyModelArr[indexPos].frequencyName
        self.selectedFrequencyValue = self.frquencyModelArr[indexPos].frequencyID
        self.dropDown.hideDropDown()
    }
    
}
