//
//  AmplifyModels.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 18/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

public protocol AmplifyRequestHelperProtocol{
    var endPoint : String {get}
    var requestParamas : [String : String] {get}
    func getUserInputText() -> String
}

public struct CoreValueAmplifyInputModel : AmplifyRequestHelperProtocol{
    public var endPoint: String{
        return "amplify-core-value-recognition"
    }
    
    public var requestParamas: [String : String]{
        return [
            "companyCoreValue" : selectedCoreValue,
            "userInputText" : userText
        ]
    }
    
    public var selectedCoreValue = ""
    public var userText = ""

    
    public init(selectedCoreValue: String = "", userText: String = "") {
        self.selectedCoreValue = selectedCoreValue
        self.userText = userText
    }
    
    public func getUserInputText() -> String{
        return userText
    }
}

public struct PostAmplifyInputModel : AmplifyRequestHelperProtocol{
    public var endPoint: String{
        return "amplify-content-post"
    }
    
    public var requestParamas: [String : String]{
        return [
            "userInputText" : userText,
            "userInputText2" : userInputText2
        ]
    }
    
    public var userText = ""
    public var userInputText2 = ""

    
    public init(userText: String = "", userInputText2: String = "") {
        self.userText = userText
        self.userInputText2 = userInputText2
    }
    
    public func getUserInputText() -> String{
        return userText
    }
}

public struct PollAmplifyInputModel : AmplifyRequestHelperProtocol{
    public var endPoint: String{
        return "amplify-content-poll"
    }
    
    public var requestParamas: [String : String]{
        return [
            "userInputText" : userText,
        ]
    }
    
    public var userText = ""

    public init(userText: String = "") {
        self.userText = userText
    }
    
    public func getUserInputText() -> String{
        return userText
    }
}

public struct EditToneAmplifyInputModel : AmplifyRequestHelperProtocol{
    public var endPoint: String{
        return "edit-tone"
    }
    
    public var requestParamas: [String : String]{
        return [
            "messageTone" : messageTone,
            "textToEdit" : textToEdit
        ]
    }
    
    private var textToEdit : String
    private var messageTone : String
   
    public init(_ textToEdit: String, messageTone: String) {
        self.textToEdit = textToEdit
        self.messageTone = messageTone
    }
    
    public func getUserInputText() -> String{
        return textToEdit
    }
}
