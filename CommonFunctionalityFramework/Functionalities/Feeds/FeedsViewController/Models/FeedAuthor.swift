//
//  FeedAuthor.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 01/05/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import Foundation

protocol FeedBaseUser{
    var rawUserDictionary : [String : Any] {get}
    func getAuthorName() -> String
    func getAuthorDepartmentName() -> String
    func getAuthorProfileImageUrl() -> String?
}

extension FeedBaseUser{
    
    func getAuthorDepartmentName() -> String {
        if let departments = rawUserDictionary["departments"] as? [[String : String]]{
            var departmentValues = [String]()
            departments.forEach { (aDictionary) in
                if let unwrappedDepartment = aDictionary["name"]{
                    departmentValues.append(unwrappedDepartment)
                }
            }
            return departmentValues.joined(separator: ", ")
        }else{
            return ""
        }
    }
    
    func getAuthorName() -> String {
        return getFullName()
    }
    
    private func getFullName() -> String{
        var name = ""
        name.append(getFirstName())
        if name.isEmpty{
            name.append(getLastName())
        }else{
            name.append(" \(getLastName())")
        }
        return name
    }
    
    private func getFirstName() -> String {
        return rawUserDictionary["first_name"] as? String ?? ""
    }
    
    private func getLastName() -> String {
        return rawUserDictionary["last_name"] as? String ?? ""
    }
    
    func getAuthorProfileImageUrl() -> String? {
        return rawUserDictionary["profile_img"] as? String
    }
}


struct FeedAuthor : FeedBaseUser {
    internal let rawUserDictionary : [String : Any]
    init(rawAuthorDictionary : [String : Any]) {
        self.rawUserDictionary = rawAuthorDictionary
    }
}
