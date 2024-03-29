//
//  InspireMeViewController.swift
//  SKOR
//
//  Created by Puneeeth on 31/01/23.
//  Copyright © 2023 Rewradz Private Limited. All rights reserved.
//

import UIKit
import RewardzCommonComponents
import SDWebImage

public protocol InspireMeDelegate {
    func aiText(userText: String)
}

enum AmpliFyMessageTone : Int, CaseIterable{
    case DEFAULT = 0
    case Casual
    case Formal
    case Shorter
    case Emoji
    
    func representation() -> String{
        switch self {
        case .DEFAULT:
            return "Expressive"
        case .Casual:
            return "Casual"
        case .Formal:
            return "Formal"
        case .Shorter:
            return "Shorter"
        case .Emoji:
            return "Emoji"
        }
    }
    
    func getToneDetails() -> String{
        switch self {
        case .DEFAULT:
            return "One paragraph casual tone"
        case .Casual:
            return "Casual"
        case .Formal:
            return "Formal"
        case .Shorter:
            return "Shorter"
        case .Emoji:
            return "Append a few relevant emojis to the end of the paragraph or within sentences to enhance the emotion of the message"
        }
    }
}

public class InspireMeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    public var themeManager: CFFThemeManagerProtocol!
    public var mainAppCoordinator : CFFMainAppInformationCoordinator!
    public var mediaCoordinator : CFFMediaCoordinatorProtocol!
    public var networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    
    @IBOutlet weak var collectionVIew: UICollectionView!
    @IBOutlet weak var holderImg: UIImageView!
    @IBOutlet weak var inspireMeGeneratedTxtField: UITextView!
    @IBOutlet weak var yourMessageLbl: UILabel!
    @IBOutlet weak var aspireMeLoadingText: UILabel?
    @IBOutlet weak var useThisBtn: UIButton!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var loaderGif: UIImageView!
    @IBOutlet weak var regenerateBtn: UIButton!
    public var inputModel : AmplifyRequestHelperProtocol!
    var aiMessage = ""
    public var delegate : InspireMeDelegate?
    @IBOutlet weak var blurImg: UIImageView!
    @IBOutlet weak var holderView: UIView!
    var label : ToolTip!
    var labelTransform : CGAffineTransform!
    let margin: CGFloat = 10
    let defaultMessageTone = "One paragraph casual tone"
    var firstFetchedOriginalText = ""
    var firstMessageCount = 0
    var shouldUsefirstFetchedOriginalText = true
    
    @IBOutlet private weak var changeLanguageContainer : UIView?
    @IBOutlet private weak var languageLabel : UILabel?
    @IBOutlet private weak var selectedLanguageLabel : UILabel?
    
    var currentlySelectedLanguageSlug : String!
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("<<<<<<<< InspireMeViewController launched")
    }
    
    private var editToneInputModel : AmplifyRequestHelperProtocol!
    private var generatedMessageRepository = [AmpliFyMessageTone : String]()
    private var currentMessageTone : AmpliFyMessageTone = .DEFAULT
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI() {
        yourMessageLbl.text = "Your message..... Amplified!".localized
        currentlySelectedLanguageSlug = mainAppCoordinator.getCurrentAppLanguage()
        self.useThisBtn.setTitle("Use".localized, for: .normal)
        self.regenerateBtn.setTitle("Regenerate".localized, for: .normal)
        aspireMeLoadingText?.text = "Amplifying message...".localized
//        self.regenerateBtn.isHidden = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        blurImg.isUserInteractionEnabled = true
        blurImg.addGestureRecognizer(tapGestureRecognizer)
        self.holderView.layer.cornerRadius = 8.0
        loadGIF()
        showLoaderByHidingElements(shouldHide: true)
        loadInspireMeText(callAmplifyModel: inputModel)
        guard let collectionView = collectionVIew, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        self.useThisBtn.backgroundColor = Rgbconverter.HexToColor(themeManager.getOrganisationBackgroundColor(), alpha: 1.0)
        self.regenerateBtn.setTitleColor(Rgbconverter.HexToColor(themeManager.getOrganisationBackgroundColor(), alpha: 1.0), for: .normal)
        setupLanguageSelectionView()
    }
    
    public func setupLanguageSelectionView(){
        /**
         we have decided to hde language selection on amplify view
         lets just keep it for a while and then emove it all together in future releases
         */
        languageLabel?.text = "Language".localized
        languageLabel?.font = .sf16Bold
        let arrayOfObjects = mainAppCoordinator.getAllAvailableLanguages()
        let matchedObject = arrayOfObjects.first { $0.slug == currentlySelectedLanguageSlug }!
        if currentlySelectedLanguageSlug == mainAppCoordinator.getCurrentAppLanguage(){
            selectedLanguageLabel?.text = "\(matchedObject.title) (\("Default".localized))"
        }else{
            selectedLanguageLabel?.text = matchedObject.title
        }
        selectedLanguageLabel?.font = .sf14Medium
    }
    
    func loadGIF(){
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "Ripple", withExtension: "gif")!)
        let advTimeGif = UIImage.sd_image(withGIFData: imageData!)
        self.loaderGif.image = advTimeGif
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showLoaderByHidingElements(shouldHide : Bool) {
        if shouldHide{
            self.inspireMeGeneratedTxtField.isHidden = true
            self.yourMessageLbl.isHidden = true
            self.useThisBtn.isHidden = true
//            self.regenerateBtn.isHidden = true
            self.holderImg.isHidden = true
            self.loaderView.isHidden = false
            self.collectionVIew.isHidden = true
            self.changeLanguageContainer?.isHidden = true
        }else {
            self.inspireMeGeneratedTxtField.isHidden = false
            self.yourMessageLbl.isHidden = false
            self.useThisBtn.isHidden = false
//            self.regenerateBtn.isHidden = false
            self.holderImg.isHidden = false
            self.loaderView.isHidden = true
            self.collectionVIew.isHidden = false
            self.changeLanguageContainer?.isHidden = false
        }
    }
    
    private func loadInspireMeText(callAmplifyModel : AmplifyRequestHelperProtocol?){
        if ConnectionManager.shared.hasConnectivity() {
            InspireMeFormWorker(networkRequestCoordinator: networkRequestCoordinator).getInspireMe(
                model: callAmplifyModel ?? inputModel,
                language: mainAppCoordinator.getLaguageNameFromSlug(currentlySelectedLanguageSlug)
            ) { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let unwrappedSelf = self else {
                        self?.showLoaderByHidingElements(shouldHide: false)
                        return
                    }
                    switch result{
                    case .Success(result: let response):
                        unwrappedSelf.showLoaderByHidingElements(shouldHide: false)
                        if let aiMessage = response["ai_message"] as? String {
                            if unwrappedSelf.firstMessageCount == 0 {
                                unwrappedSelf.firstFetchedOriginalText = aiMessage
                                unwrappedSelf.firstMessageCount = 1
                            }
                            unwrappedSelf.generatedMessageRepository[unwrappedSelf.currentMessageTone] = aiMessage
                            unwrappedSelf.aiMessage = aiMessage
                            unwrappedSelf.inspireMeGeneratedTxtField.text = aiMessage
                        }
                        unwrappedSelf.collectionVIew.reloadData()
                    case .Failure(_):
                        let error =  ConnectionManager.shared.hasConnectivity() ? "Please try to amplify again.".localized : "The Internet connection appears to be offline.".localized
                        unwrappedSelf.showAlert(title: NSLocalizedString("Error", comment: ""), message: error)
                    case .SuccessWithNoResponseData:
                        unwrappedSelf.showAlert(title: NSLocalizedString("Error", comment: ""), message: "Please try to amplify again.".localized)
                    }
                }
            }
        }else {
            showAlert(title: NSLocalizedString("Error", comment: ""), message: "The Internet connection appears to be offline.".localized)
        }
    }
    
    
    @IBAction func useThisBtnPressed(_ sender: Any) {
        //        commonToolTipDisplay(toolTipLbl: label, transformLbl: labelTransform, disableToolTip: label, disableTransformLbl: labelTransform)
        //        UIPasteboard.general.string = self.aiMessage
        delegate?.aiText(userText: self.aiMessage)
        self.dismiss(animated: true)
    }
    
    @IBAction func regenerateBtnPressed(_ sender: Any) {
        
        shouldUsefirstFetchedOriginalText = true
        generatedMessageRepository = [AmpliFyMessageTone: String]()
        if currentMessageTone == .DEFAULT{
            showLoaderByHidingElements(shouldHide: true)
            loadInspireMeText(callAmplifyModel: nil)
        }else {
            showLoaderByHidingElements(shouldHide: true)
            loadInspireMeText(
                callAmplifyModel: EditToneAmplifyInputModel(
                    firstFetchedOriginalText,
                    messageTone: currentMessageTone.getToneDetails()
                )
            )
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AmpliFyMessageTone.allCases.count //arrayHolder.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! InpiremeOptionCollectionViewCell
        let messageTone = AmpliFyMessageTone.allCases[indexPath.row]
        cell.inspireMeOptionLbl.text = messageTone.representation().localized //dataValues.localized
        cell.layer.cornerRadius = 8.0
        if  currentMessageTone == messageTone {
            cell.backgroundColor = UIColor.getControlColor()
            cell.inspireMeOptionLbl.textColor = .white
        }else {
            cell.backgroundColor = .white
            cell.inspireMeOptionLbl.textColor = .gray
        }
        cell.layer.borderWidth = 0.5
        cell.layer.borderUIColor = .getControlColor()
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentMessageTone = AmpliFyMessageTone.allCases[indexPath.row]
        let userStringORAiString = shouldUsefirstFetchedOriginalText ? firstFetchedOriginalText : inputModel.getUserInputText()
        if let cachedMessage = generatedMessageRepository[currentMessageTone]{
            self.inspireMeGeneratedTxtField.text = cachedMessage
            self.aiMessage = cachedMessage
            self.collectionVIew.reloadData()
        }else{
            if currentMessageTone == .DEFAULT{
                loadInspireMeText(callAmplifyModel: inputModel)
            }else{
                loadInspireMeText(
                    callAmplifyModel: EditToneAmplifyInputModel(
                        userStringORAiString,
                        messageTone: currentMessageTone.getToneDetails()
                    )
                )
            }
            showLoaderByHidingElements(shouldHide: true)
        }
    }
    
    // MARK: - Tooltip show and hide common function
    func commonToolTipDisplay(toolTipLbl: ToolTip, transformLbl:  CGAffineTransform, disableToolTip: ToolTip, disableTransformLbl: CGAffineTransform) {
        if toolTipLbl.transform.ty > 0 {
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { () -> Void in
                toolTipLbl.transform =  .identity
            }, completion:    nil)
        }
        else {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations:  { () -> Void in
                toolTipLbl.alpha = 0
            }, completion:    {_ in
                toolTipLbl.transform = transformLbl
                toolTipLbl.alpha = 1
            })
        }
        
        UIView.animate(withDuration: 2.5, delay: 0, options: .curveEaseIn, animations:  { () -> Void in
            disableToolTip.alpha = 0
        }, completion:    {_ in
            disableToolTip.transform = disableTransformLbl
            disableToolTip.alpha = 1
        })
    }
    
    // MARK: - ToolTip
    func drawToolTip(toolTipButton: UIButton, text: String) {
        label = ToolTip()
        view.insertSubview(label, belowSubview: toolTipButton)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        label.widthAnchor.constraint(equalToConstant: 70).isActive = true
        label.bottomAnchor.constraint(equalTo: toolTipButton.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: toolTipButton.centerXAnchor).isActive = true
        label.text = text
        label.font = UIFont(name: "Helvetica", size: 12.0)
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        label.textColor =  UIColor.white
        label.textAlignment = .center
        let trans1 =  CGAffineTransform(scaleX: 0, y: 0)
        let trans2 =  CGAffineTransform(translationX: 0, y: 100)
        labelTransform = trans1.concatenating(trans2)
        label.transform = labelTransform
    }
    
}

extension InspireMeViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 3 || indexPath.row == 4 {
            let noOfCellsInRow = 2   //number of column you want
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            return CGSize(width: size, height: 39)
        }else {
            let noOfCellsInRow = 3   //number of column you want
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            return CGSize(width: size, height: 39)
        }
       
    }
    
}

extension InspireMeViewController : DropDownProtocol{
    @IBAction private func changeLanguageTapped(){
        let languaePickerVC = CommonDropDownPickerViewController(
            nibName: "CommonDropDownPickerViewController",
            bundle: Bundle(for: CommonDropDownPickerViewController.classForCoder())
        )
        languaePickerVC.delegate = self
        languaePickerVC.languageNames = mainAppCoordinator.getAllAvailableLanguages()
        languaePickerVC.selectedSlug = currentlySelectedLanguageSlug
        languaePickerVC.modalPresentationStyle = .overCurrentContext
        self.present(languaePickerVC, animated: true, completion: nil)
    }
    
    public func selectedValue(index : Int) {
        currentlySelectedLanguageSlug = mainAppCoordinator.getAllAvailableLanguages()[index].slug
        setupLanguageSelectionView()
    }
}
