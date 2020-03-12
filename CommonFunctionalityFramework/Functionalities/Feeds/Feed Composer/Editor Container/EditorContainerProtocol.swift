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

public protocol EditorContainerProtocol {
    var topBarItems : EditorContainerTopBarModel{get}
}
