//
//  OutsandingImageTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Puneeeth on 14/06/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation


class OutsandingImageTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonOutastandingImageTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 293
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonOutastandingImageTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            let feedNominationData = feed.getStrengthData()
            let bagesData = feed.getBadgesData()
            cell.strengthLabel?.text = feedNominationData["strengthName"] as? String ?? ""
            cell.strengthHeightConstraints?.constant = cell.strengthLabel?.text?.isEmpty ?? true ? 0 : 20
            if let unwrappedText = feed.getFeedDescription(){
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: feed.feedIdentifier, description: unwrappedText)
                ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                    cell.nominationMessage?.text = nil
                    cell.nominationMessage?.attributedText = attr
                })
                
                if cell.nominationMessage!.maxNumberOfLines > 3 {
                    let readmoreFont = UIFont(name: "SFProText-Regular", size: 14)
                    let readmoreFontColor = UIColor.getControlColor()
                    DispatchQueue.main.async {
                        cell.nominationMessage?.addTrailing(with: "... ", moreText: "Read More", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                    }
                }
            }else{
                cell.nominationMessage?.text = feedNominationData["strengthMessage"] as? String ?? ""
                if cell.nominationMessage!.maxNumberOfLines > 3 {
                    let readmoreFont = UIFont(name: "SFProText-Regular", size: 14)
                    let readmoreFontColor = UIColor.getControlColor()
                    DispatchQueue.main.async {
                        cell.nominationMessage?.addTrailing(with: "... ", moreText: "Read More", moreTextFont: readmoreFont!, moreTextColor: readmoreFontColor)
                    }
                }
            }
            
            if let badgeData = bagesData as? NSDictionary {
                if bagesData.count > 0 {
                    cell.awardLabel?.text = badgeData["badgeName"] as! String
                    cell.nominationImageView?.backgroundColor =  Rgbconverter.HexToColor(badgeData["badgeBackgroundColor"] as! String, alpha: 1)
                    cell.imageContainer?.backgroundColor = Rgbconverter.HexToColor(badgeData["badgeBackgroundColor"] as! String, alpha: 1)
                    cell.nominationConatiner?.backgroundColor = Rgbconverter.HexToColor(badgeData["badgeBackgroundColor"] as! String, alpha: 0.2)
                    
                    inputModel.mediaFetcher.fetchImageAndLoad(cell.badgeImageView, imageEndPoint:  badgeData["badgeIcon"] as! String)
                }
  
            }
            
            let strengthIcon = feedNominationData["strengthIcon"] as? String ?? ""
            if !strengthIcon.isEmpty {
                inputModel.mediaFetcher.fetchImageAndLoad(cell.strengthIcon, imageEndPoint: URL(string: serverUrl+strengthIcon))
            }else {
                cell.strengthIcon?.image = UIImage(named: "PlaceHolderImage")
            }
            
            if !strengthIcon.isEmpty {
                inputModel.mediaFetcher.fetchImageAndLoad(cell.categoryImageView, imageEndPoint: URL(string: serverUrl+strengthIcon))
            }else {
                cell.categoryImageView?.image = UIImage(named: "PlaceHolderImage")
            }
            
            cell.categoryName?.text = "Suyesh"
            cell.badgeName?.text = bagesData["badgeName"] as? String ?? ""
            cell.badgePoints?.text = bagesData["points"] as? String ?? ""
        }
    }
    
}


extension UILabel{
    
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            
            let mutableString: String = myText
            
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(in: NSRange(location: lengthForVisibleString, length: myText.count - lengthForVisibleString), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
            print("this number \(safeTrimmedString.count) should never be less\n")
            print("then this number \(readMoreLength)")
            
            // "safeTrimmedString.count - readMoreLength" should never be less then the readMoreLength because it'll be a negative value and will crash
            let trimmedForReadMore: String = (safeTrimmedString as NSString).replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength, length: readMoreLength), with: "") + trailingText
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes: [NSAttributedString.Key.font: self.font])
            let readMoreAttributed = NSMutableAttributedString(string: moreText, attributes: [NSAttributedString.Key.font: moreTextFont, NSAttributedString.Key.foregroundColor: UIColor.getControlColor()])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }
    
    var visibleTextLength: Int {
        
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        if let myText = self.text {
            
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: myText, attributes: attributes as? [NSAttributedString.Key : Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString).rangeOfCharacter(from: characterSet, options: [], range: NSRange(location: index + 1, length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString).substring(to: index).boundingRect(with: sizeConstraint, options: .usesLineFragmentOrigin, attributes: attributes as? [NSAttributedString.Key : Any], context: nil).size.height <= labelHeight
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
}
