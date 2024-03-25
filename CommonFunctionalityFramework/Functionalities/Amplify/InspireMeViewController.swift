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
    func aiText(contentData : NSDictionary)
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
    public var isJSONRequired : Bool = true
    
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
    var amplifyData : NSDictionary?
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
    var editTonePayload = [[String : String]]()
    var editToneData = [String: Any]()
    var messageWithOptions: AIMessageWithContent?
    var postType : String = "post"
    var userSelectedLanguage : String = ""
    
    @IBOutlet private weak var changeLanguageContainer : UIView?
    @IBOutlet private weak var languageLabel : UILabel?
    @IBOutlet private weak var selectedLanguageLabel : UILabel?
    
    var currentlySelectedLanguageSlug : String!
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        debugPrint("<<<<<<<< InspireMeViewController launched")
    }
    
    private var editToneInputModel : AmplifyRequestHelperProtocol!
    private var generatedMessageRepository = [AmpliFyMessageTone : NSAttributedString]()
    private var currentMessageTone : AmpliFyMessageTone = .DEFAULT
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    func setUpUI() {
        yourMessageLbl.text = "Your message..... Amplified!".localized
        currentlySelectedLanguageSlug = mainAppCoordinator.getCurrentAppLanguage()
        self.userSelectedLanguage = self.mainAppCoordinator.getLaguageNameFromSlug(currentlySelectedLanguageSlug)
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
                language: mainAppCoordinator.getLaguageNameFromSlug(currentlySelectedLanguageSlug), 
                isRequestJson: self.isJSONRequired, 
                editToneData: self.editToneData
            ) { [weak self] (result) in
                DispatchQueue.main.async {
                    guard let unwrappedSelf = self else {
                        self?.showLoaderByHidingElements(shouldHide: false)
                        return
                    }
                    switch result{
                    case .Success(result: let response):
                        unwrappedSelf.showLoaderByHidingElements(shouldHide: false)
                        if let aiMessage = response["ai_message"] as? NSDictionary {
                            if unwrappedSelf.firstMessageCount == 0 {
                                unwrappedSelf.firstFetchedOriginalText = aiMessage.object(forKey: "content") as? String ?? ""
                                unwrappedSelf.firstMessageCount = 1
                            }
                            if let unwrppedContent = aiMessage.object(forKey: "content") as? String {
                                let options = [aiMessage.object(forKey: "title") as? String ?? "", unwrppedContent]
                                let messageWithContent = AIMessageWithContent(content: options, count: options.count)
                                self?.messageWithOptions = messageWithContent
                                self?.editToneData = (self?.formatData(messageWithOptions: messageWithContent, messageTone: (self?.currentMessageTone.getToneDetails())!, language: self?.userSelectedLanguage ?? "English", type: self?.postType ?? "post"))!
                                unwrappedSelf.aiMessage = unwrppedContent
                                let aiMessage = Message(title: aiMessage.object(forKey: "title") as? String ?? "", content: unwrppedContent)
                                let formattedMessage = aiMessage.formattedMessage()
                                unwrappedSelf.inspireMeGeneratedTxtField.attributedText = formattedMessage
                                unwrappedSelf.generatedMessageRepository[unwrappedSelf.currentMessageTone] = formattedMessage
                                
                                
                            }
                            
                            if let _ = aiMessage.object(forKey: "Option 1 text") as? String {
                                if let unwrppedContent = aiMessage.object(forKey: "title") as? String {
                                    
                                    let title = aiMessage.object(forKey: "title") as? String ?? ""
                                    
                                    
                                    unwrappedSelf.aiMessage = unwrppedContent
                                    let aiPoll = PollContent(options: [
                                        "1 text": aiMessage.object(forKey: "Option 1 text") as? String ?? "",
                                        "2 text": aiMessage.object(forKey: "Option 2 text") as? String ?? "",
                                        "3 text": aiMessage.object(forKey: "Option 3 text") as? String ?? "",
                                        "4 text": aiMessage.object(forKey: "Option 4 text") as? String ?? ""
                                    ], question: unwrppedContent)

                                    let formattedPoll = aiPoll.formattedPoll()
                                    unwrappedSelf.inspireMeGeneratedTxtField.attributedText = formattedPoll
                                    unwrappedSelf.generatedMessageRepository[unwrappedSelf.currentMessageTone] = formattedPoll
                                    let options = [title, aiMessage.object(forKey: "Option 1 text") as? String ?? "", aiMessage.object(forKey: "Option 2 text") as? String ?? "", aiMessage.object(forKey: "Option 3 text") as? String ?? "", aiMessage.object(forKey: "Option 4 text") as? String ?? ""]
                                    let messageWithOptions = AIMessageWithContent(content: options, count: options.count)
                                    self?.messageWithOptions = messageWithOptions
                                    self?.editToneData = (self?.formatData(messageWithOptions: messageWithOptions, messageTone: (self?.currentMessageTone.getToneDetails())!, language: self?.userSelectedLanguage ?? "English", type: self?.postType ?? "poll"))!
                                }
                            }
                            
                            
                            unwrappedSelf.amplifyData = aiMessage
                        }else if let aiMessage = response["ai_message"] as? String {
                            if unwrappedSelf.firstMessageCount == 0 {
                                unwrappedSelf.firstFetchedOriginalText = aiMessage
                                unwrappedSelf.firstMessageCount = 1
                            }
                            unwrappedSelf.generatedMessageRepository[unwrappedSelf.currentMessageTone] = NSAttributedString(string: aiMessage)
                            unwrappedSelf.aiMessage = aiMessage
                            unwrappedSelf.inspireMeGeneratedTxtField.text = aiMessage
                            unwrappedSelf.amplifyData = response
                        }else {
                            if unwrappedSelf.firstMessageCount == 0 {
                                unwrappedSelf.firstFetchedOriginalText = ""
                                unwrappedSelf.firstMessageCount = 0
                            }
                            unwrappedSelf.generatedMessageRepository[unwrappedSelf.currentMessageTone] = NSAttributedString(string: "")
                            unwrappedSelf.aiMessage = ""
                            unwrappedSelf.inspireMeGeneratedTxtField.text = ""
                            unwrappedSelf.amplifyData = NSDictionary()
                            unwrappedSelf.showAlert(title: NSLocalizedString("Error", comment: ""), message: "Please try to amplify again.".localized)
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
        if let unwrappedAmplifyData = self.amplifyData {
            delegate?.aiText(contentData: unwrappedAmplifyData)
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func regenerateBtnPressed(_ sender: Any) {
        
        shouldUsefirstFetchedOriginalText = true
        generatedMessageRepository = [AmpliFyMessageTone: NSAttributedString]()
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
        if let unwrapedContent = messageWithOptions {
            self.editToneData = (self.formatData(messageWithOptions: unwrapedContent, messageTone: (self.currentMessageTone.getToneDetails()), language: self.userSelectedLanguage , type: self.postType ))
        }
        
        if let cachedMessage = generatedMessageRepository[currentMessageTone]{
            self.inspireMeGeneratedTxtField.attributedText = cachedMessage
            self.aiMessage = ""
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
    
    // Function to format the AI message data into the required input format
    func formatData(messageWithOptions: AIMessageWithContent, messageTone: String, language: String,type : String) -> [String: Any] {
        self.editTonePayload.removeAll()
        for i in 0..<messageWithOptions.count {
            var selectedReceiptData : [String : String]!
            selectedReceiptData = [
                "textToEdit" : "\(messageWithOptions.content[i])",
                "messageTone": messageTone,
                "language": language]
            self.editTonePayload.append(selectedReceiptData)
        }
        
        // Construct the dictionary with the "inputs" key
        let finalDictionary: [String: Any] = ["inputs": self.editTonePayload,"content_type" : type]
        return finalDictionary
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
struct Message {
    var title: String
    var content: String

    func formattedMessage() -> NSAttributedString {
        let boldTitle = "\(title)"
        let attributedString = NSMutableAttributedString(string: boldTitle + "\n \n")
        let contentAttributedString = NSAttributedString(string: "\(content)")
        attributedString.append(contentAttributedString)

        // Apply bold font to title
        let titleRange = NSRange(location: 0, length: boldTitle.count)
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        attributedString.addAttributes(titleAttributes, range: titleRange)

        return attributedString
    }
}

struct PollContent {
    var options: [String: String]
    var question: String

    func formattedPoll() -> NSAttributedString {
        let boldQuestion = "\(question)"
        let formattedString = NSMutableAttributedString(string: "\(boldQuestion)\n\n")

        for (index, option) in options.sorted(by: { $0.key < $1.key }) {
            let optionString = "\(option)\n \n"
            let attributedOption = NSAttributedString(string: optionString)
            formattedString.append(attributedOption)
        }

        // Apply bold font to title
        let titleRange = NSRange(location: 0, length: boldQuestion.count)
        let titleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        formattedString.addAttributes(titleAttributes, range: titleRange)
        return formattedString
    }
}

// Define a struct to represent the AI message with content
struct AIMessageWithContent {
    let content: [String]
    let count : Int
}


