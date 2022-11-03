//
//  FeedDescriptionParser.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 16/07/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit
import CoreData

/// Markup tags which can be parsed
enum MarkupTag : String,CaseIterable{
    case None
    case Gif = "gif"
    case Tag = "tag<deprecated>"
}


/// Output model after the parsing of a tag
struct MarkupModel{
    var tag : MarkupTag
    var content : String
    
    func stringRepresentation() {
        print("\(tag.rawValue) -- \(content)")
    }
}

/// Output model after the parsing of complete markup string for all possible types of tags
struct FeedDescriptionParserOutPutModel{
    var displayableDescription : NSAttributedString
    var attachedGif : String?
}

/// Markup parser for the description strings, which provides the parsed mark up model for an input description string of a feed. It maintains an in memory cache as well for the parsed string so that it need not parse the string everytime.
class FeedDescriptionMarkupParser : NSObject{
    
    static let sharedInstance = FeedDescriptionMarkupParser()
    private override init() {
        super.init()
    }
    
    private var paserOutputRepository = [Int64 : FeedDescriptionParserOutPutModel]()
    
    /// Provides the cleaned description string and attached gif element
    /// - Parameters:
    ///   - feedId: feed identifier
    ///   - description: feed description text
    /// - Returns: Output model after the parsing of complete markup string for all possible types of tags
    @discardableResult func getDescriptionParserOutputModelForFeed(feedId: Int64, description: String?) -> FeedDescriptionParserOutPutModel? {
        if let unwrappedDescription = description{
            if
              feedId >= 0,//check for editable post which has a feed id of -1
                let cachedModel = paserOutputRepository[feedId]{
                return cachedModel
            }else{
                let model = parseDescriptionText(unwrappedDescription)
                paserOutputRepository[feedId] = model
                return model
            }
        }else{
            paserOutputRepository.removeValue(forKey: feedId)
            return nil
        }
        
    }
    
    /// update feed description model after post is updated
    /// - Parameters:
    ///   - feedId: feed identifier
    ///   - description: feed description text
    func updateDescriptionParserOutputModelForFeed(feedId: Int64, description: String?){
        if let unwrappedDescription = description{
            let model = parseDescriptionText(unwrappedDescription)
            paserOutputRepository[feedId] = model
        }else{
            paserOutputRepository.removeValue(forKey: feedId)
        }
    }
    
    private func parseDescriptionText(_ input : String) -> FeedDescriptionParserOutPutModel{
        let allComponents =  getComponents(markupTag: .Gif, input: input)
        let gifComponents = allComponents.filter { (aModel) -> Bool in
            return aModel.tag == .Gif
        }

        let plainTextComponents = allComponents.filter { (aModel) -> Bool in
            return aModel.tag != .Gif
        }

        var textComponentsWithoutGif = [String]()
        plainTextComponents.forEach { (model) in
            textComponentsWithoutGif.append(model.content)
        }
        let modifiedDescriptionWithoutGifTags = textComponentsWithoutGif.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        let tagComponents =  getComponents(markupTag: .Tag, input: modifiedDescriptionWithoutGifTags)

        var modifiedDescriptionWithTags = [String]()

        let attributaedDescription = NSMutableAttributedString()

        tagComponents.forEach { (model) in
            switch model.tag {
            case .None:
                if (!model.content.isEmpty) || (model.content != "\n"){
                    attributaedDescription.append(NSAttributedString(string: "\(model.content) "))
                    modifiedDescriptionWithTags.append(model.content)
                }
                
            case .Gif:
                print("do nothing")
            case .Tag:
                print("do nothing")
//                let font = UIFont.systemFont(ofSize: 72)
//                let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor : UIColor.red]
//                attributaedDescription.append(NSAttributedString(string: "@\(model.content) ", attributes: attributes))
//                modifiedDescriptionWithTags.append("@\(model.content)")
            }
        }

        return FeedDescriptionParserOutPutModel(displayableDescription: attributaedDescription, attachedGif: gifComponents.first?.content)
    }
    
    private func getComponents(markupTag : MarkupTag, input: String) -> [MarkupModel]{
        var finalComponents = [MarkupModel]()
        let components =  input.components(separatedBy: "<\(markupTag.rawValue)>")
        if components.count == 1{
            return [MarkupModel(tag: .None, content: input)]
        }else{
            for aComponent in components {
                let endTag = "</\(markupTag.rawValue)>"
                if aComponent.contains(endTag){
                    for (index, endTagComponent) in aComponent.components(separatedBy: "</\(markupTag.rawValue)>").enumerated() {
                        if index == 0{
                            finalComponents.append(MarkupModel(tag: markupTag, content: endTagComponent))
                        }else{
                            finalComponents.append(contentsOf: getComponents(markupTag: markupTag, input: endTagComponent))
                        }
                    }
                }else{
                   finalComponents.append(MarkupModel(tag: .None, content: aComponent))
                }
            }
        }
        
        return finalComponents
    }

}

