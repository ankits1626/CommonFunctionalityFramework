//
//  CommonTableCollection.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 03/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit


struct CommonTableCollectioneError {
    static let UnExpectedViewTypeError = NSError(
        domain: "com.CommonFunctionality.CommonTableCollectioneError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unexpected view was sent to CommonTableCollection ."]
    )
}

class CommonTableCollection : CommonCollectionTypeProtocol {
    func dequeueCell(identifier:String, indexpath: IndexPath) -> CommonCollectionCellProtocol {
        //TO DO: better error handling can be done we make this method throw error
        return containedTableView?.dequeueReusableCell(withIdentifier: identifier, for: indexpath) as! CommonCollectionCellProtocol
    }
    
    private weak var containedTableView : UITableView?
    
    required init(containedCollection: UIView) throws {
        if let unwrappedTableView = containedCollection as? UITableView{
            self.containedTableView = unwrappedTableView
        }else{
            throw CommonTableCollectioneError.UnExpectedViewTypeError
        }
        
    }
    
    func registerCollectionForCell(type : CommomCollectionCellTypeProtocol) throws{
        containedTableView?.register(
            type.cellNib,
            forCellReuseIdentifier: type.cellTypeIdentifier
        )
    }
    
}
