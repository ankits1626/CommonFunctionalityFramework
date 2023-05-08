//
//  TopHeroesModel.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 30/03/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

struct TopHeroesFetchedData {
    private var categories = [TopHeroesCategory]()
    private var heroes =  [TopRecognitionHero]()
    
    mutating func setCategories(_ categories :  [TopHeroesCategory]){
        self.categories = categories
    }
    
    func getCategories () -> [TopHeroesCategory]  {
        return categories
    }
    
    mutating func setHeroes(_ heroes :  [TopRecognitionHero]){
        self.heroes = heroes
    }
    
    func getHeroes () -> [TopRecognitionHero]  {
        return heroes
    }
}

struct TopHeroesCategory {
    var categoryName : String
    var selectedIcon : String?
    var nonSelectedIcon : String?
    var categoryDescription : String?
    var slug : String
    
    init(_ rawCategory : [String : Any]) {
        self.categoryName = rawCategory["name"] as? String ?? ""
        self.selectedIcon = rawCategory["icon"] as? String
        self.nonSelectedIcon = rawCategory["disabled_icon"] as? String
        self.categoryDescription = rawCategory["description"] as? String
        self.slug = rawCategory["slug"] as? String ?? ""
    }
    
    func getCategoryIconUrl(_ isSelected: Bool) -> URL? {
        return isSelected ? getSelectedCategoryIconUrl() : getNonSelectedCategoryIconUrl()
    }
    
    private func getSelectedCategoryIconUrl() -> URL? {
        if let unwrappedSelectedIcronURL = selectedIcon{
            return URL(string: unwrappedSelectedIcronURL)
        }else{
            return nil
        }
    }
    
    private func getNonSelectedCategoryIconUrl() -> URL? {
        if let unwrappedSelectedIcronURL = nonSelectedIcon{
            return URL(string: unwrappedSelectedIcronURL)
        }else{
            return nil
        }
    }
}
struct AppreciationRatio: Decodable {
  let given: String
  let received: String
}

struct TopRecognitionHero {
  private var firstName : String
  private var lastName : String
  private var employeeId : String?
  var heroPK : Int
  var email : String?
  var profileImage : String?
  var appreciationRatio: AppreciationRatio
  var category: String = ""
  var remainingPoints : Double?
  var monthlyAppreciationLimit : Int?
  var name : String{
    get{
      if firstName.isEmpty && lastName.isEmpty {
        return email ?? ""
      }
      return "\(firstName) \(lastName)"
    }
  }
    
    init(_ rawHero : [String : Any]) {
      self.firstName = rawHero["first_name"] as? String ?? "-"
      self.lastName = rawHero["last_name"] as? String ?? "-"
      self.employeeId = rawHero["employee_id"] as? String ?? "-"
      self.email = rawHero["email"] as? String
      self.profileImage = rawHero["profile_pic_url"] as? String
      if let data = try? JSONSerialization.data(withJSONObject: rawHero["appreciation_ratio"] as! [String: Any], options: .prettyPrinted) {
//        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let ratio = try! JSONDecoder().decode(AppreciationRatio.self, from: data)
        self.appreciationRatio = ratio
      } else {
        appreciationRatio = AppreciationRatio(given: "0", received: "0")
      }
      self.heroPK = rawHero["pk"] as? Int ?? -1
    }
    
    func getProfileImageUrl() -> String? {
        if let profileImage = self.profileImage,
            !profileImage.isEmpty{
            return profileImage
        }else{
            return ""
        }
    }
    
    func getFullName() -> String {
        var fullName : String = ""
        if !self.firstName.isEmpty {
            fullName = self.firstName + " "
        }
        if !self.lastName.isEmpty {
            fullName = fullName + self.lastName
        }
        return fullName
    }
    
    func getMetric() -> String {
      return appreciationRatio.received
    }
}

