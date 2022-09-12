//
//  CommonAppreciationSubjectTableViewCellCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 04/05/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import Foundation

class CommonAppreciationSubjectTableViewCellCoordinator: CommonFeedCellCoordinatorProtocol{
    
    var cellType: CommonFeedCellTypeProtocol{
        return CommonAppreciationSubjectTableViewCellType()
    }
    
    func getCell(_ inputModel: FeedCellDequeueModel) -> UITableViewCell {
        return inputModel.targetTableView.dequeueReusableCell(
            withIdentifier: cellType.cellIdentifier,
            for: inputModel.targetIndexpath)
    }
    
    func getHeight(_ inputModel: CommonFeedCellGetHeightModel) -> CGFloat {
        return 132
    }
    
    func loadDataCell(_ inputModel: CommonFeedCellLoadDataModel) {
        if let cell  = inputModel.targetCell as? CommonAppreciationSubjectTableViewCell{
            let feed = inputModel.datasource.getFeedItem(inputModel.targetIndexpath.section)
            let feedTitle = feed.getStrengthData()
            if let unwrappedText = feedTitle["strengthMessage"] as? String{
                let model = FeedDescriptionMarkupParser.sharedInstance.getDescriptionParserOutputModelForFeed(feedId: feed.feedIdentifier, description: unwrappedText)
                ASMentionCoordinator.shared.getPresentableMentionText(model?.displayableDescription.string, completion: { (attr) in
                    cell.feedText?.text = nil
                    cell.feedText?.attributedText = attr
                })
            }else{
                cell.feedText?.text = feedTitle["strengthMessage"] as? String ?? ""
            }
            
            cell.appreciationSubject?.text =  feedTitle["strengthName"] as? String ?? ""
            if let numberOfComments = cell.feedText {
                if numberOfComments.maxNumberOfLines > 3 {
                    cell.readMorebutton?.isHidden = false
                }else {
                    cell.readMorebutton?.isHidden = true
                }
            }
            let attributedString = NSAttributedString(string: NSLocalizedString("Read More", comment: ""), attributes:[
                NSAttributedString.Key.font : UIFont(name: "SFProText-Bold", size: 10.0),
                NSAttributedString.Key.foregroundColor : UIColor.getControlColor(),
                NSAttributedString.Key.underlineStyle:1.0
            ])
            cell.readMorebutton?.setAttributedTitle(attributedString, for: .normal)
            cell.feedText?.numberOfLines = 3
            inputModel.mediaFetcher.fetchImageAndLoad(cell.feedThumbnail, imageEndPoint: feedTitle["illustration"] as? String ?? "")
//            cell.containerView?.backgroundColor = Rgbconverter.HexToColor(feedTitle["badgeBackgroundColor"] as? String ?? "", alpha: 1.0)
            
            let backGroundColor = feedTitle["badgeBackgroundColor"] as? String ?? ""
            let backGroundColorLite = feedTitle["background_color_lite"] as? String ?? ""
            if let bgColor = UIColor(hex: backGroundColorLite) {
                cell.containerView?.backgroundColor = bgColor
            }else{
                cell.containerView?.backgroundColor = Rgbconverter.HexToColor(backGroundColor)
            }
            
//            cell.containerView?.curvedUIBorderedControl(borderColor: .clear, borderWidth: 1.0, cornerRadius: 8.0)
//
            
            cell.containerView?.clipsToBounds = true
            cell.containerView?.layer.cornerRadius = 8
            cell.containerView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
//            if let mediaItem = feed.getMediaList()?.first,
//                let _ = mediaItem.getCoverImageUrl(){
//                cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 8)
//            }else if let gifItem = feed.getGiphy() {
//                if !gifItem.isEmpty {
//                    cell.containerView?.roundCorners(corners: [.topLeft, .topRight], radius: 8)
//                }
//            }else {
//                cell.containerView?.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8)
//            }
        }
    }
    
}



extension UIView {
//   func roundCorners(corners: UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        layer.mask = mask
//    }
}

extension UILabel {
    var maxNumberOfLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = (self.text ?? "") as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}
