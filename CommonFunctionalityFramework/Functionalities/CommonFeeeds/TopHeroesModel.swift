//
//  TopHeroesModel.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 30/03/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation
import RewardzCommonComponents

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
    
    func getNumberOfHeroes() -> Int {
        if heroes.count == 0  || heroes.count == 1{
            return heroes.count
        }
        if heroes.count == 2 {
            return heroes.count - 1
        }
        return heroes.count - 2
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
  var departmentName : String?
  var appreciationRatio: AppreciationRatio
  var recognitionType : String?
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
    
    init(_ rawHero : [String : Any], recognitionTye : String) {
      self.firstName = rawHero["first_name"] as? String ?? "-"
      self.lastName = rawHero["last_name"] as? String ?? "-"
      self.employeeId = rawHero["employee_id"] as? String ?? "-"
      self.email = rawHero["email"] as? String
      self.profileImage = rawHero["profile_pic_url"] as? String
      self.departmentName = rawHero["department_name"] as? String ?? "N/A"
        self.recognitionType = recognitionTye
      if let data = try? JSONSerialization.data(withJSONObject: rawHero["appreciation_ratio"] as! [String: Any], options: .prettyPrinted) {
//        let decoded = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let ratio = try! JSONDecoder().decode(AppreciationRatio.self, from: data)
        self.appreciationRatio = ratio
      } else {
        appreciationRatio = AppreciationRatio(given: "0", received: "0")
      }
      self.heroPK = rawHero["pk"] as? Int ?? -1
    }
    
    func getAppreciationRatio() -> String {
        if self.recognitionType == "given" {
            return self.appreciationRatio.given
        }else if self.recognitionType == "received" {
            return self.appreciationRatio.received
        }else {
            let total = (Int(self.appreciationRatio.given) ?? 0) + (Int(self.appreciationRatio.received) ?? 0)
            return "\(total)"
        }
    }
    
    func getProfileImageUrl() -> URL? {
        if let profileImage = self.profileImage,
            !profileImage.isEmpty{
            let serverUrl = UserDefaults.standard.value(forKey: "base_url_for_image_height") as? String ?? ""
            return URL(string: serverUrl+profileImage)
        }else{
            return nil
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
        
        if fullName.isEmpty {
            return self.email ?? ""
        }
        return fullName
    }
    
    func getMetric() -> String {
      return appreciationRatio.received
    }
}

