//
//  EditorContainerProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 12/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

public struct EditorContainerTopBarModel{
    var title : UILabel?
    var attachPDFButton : UIButton?
    var cameraButton : UIButton?
    
    public init(title : UILabel? , attachPDFButton : UIButton?, cameraButton : UIButton?){
        self.title = title
        self.attachPDFButton = attachPDFButton
        self.cameraButton = cameraButton
    }
}

public enum GenericContainerPresentationOption{
    case Present
    case Navigate
}

public protocol EditorContainerProtocol {
    var topBarItems : EditorContainerTopBarModel{get}
}

public struct GenericContainerTopBarModel{
    var title : UILabel?
    var leftButton : UIButton?
    var rightButton : UIButton?
    
    public init(title : UILabel? , leftButton : UIButton?, rightButton : UIButton?){
        self.title = title
        self.leftButton = leftButton
        self.rightButton = rightButton
    }
}

public protocol GenericContainerProtocol{
    var presentationStyle : GenericContainerPresentationOption {get set}
    var topBarItems : GenericContainerTopBarModel{get}
}
