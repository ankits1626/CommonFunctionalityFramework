//
//  LeaderboardModel.swift
//  Leaderboard
//
//  Created by Suyesh Kandpal on 28/05/22.
//

import Foundation
import UIKit


//enum RedemptionStatus : Int, CaseIterable{
//    case NA = 0
//    case RedeemedNotUsed
//    case Used
//    case Received
//    case Expired
//    case InProcess
//    case Shipped
//    case OutOfStock
//    case ReadyForPickup
//    case VoucherUsed
//
//
//    func getPresentableRedemptionStatus(redemption: Redemption) -> PresentableRedemptionStatus {
//        switch self {
//        case .NA:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "",
//                showcategory: true,
//                slug: "\(RedemptionStatus.RedeemedNotUsed.rawValue)"
//            )
//        case .RedeemedNotUsed:
//            return PresentableRedemptionStatus(
//                title: "Not Used".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.RedeemedNotUsed.rawValue)"
//            )
//        case .Used:
//            return PresentableRedemptionStatus(
//                title:  redemption.isCashRedemption() ? "Processed".localized : "Used".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.Used.rawValue)"
//            )
//        case .Received:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "Received".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.Received.rawValue)"
//            )
//        case .Expired:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "Expired",
//                showcategory: true,
//                slug: "\(RedemptionStatus.Received.rawValue)"
//            )
//        case .InProcess:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "In Process".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.InProcess.rawValue)"
//            )
//        case .Shipped:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "Shipped".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.Shipped.rawValue)"
//            )
//        case .OutOfStock:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "Out Of Stock",
//                showcategory: true,
//                slug: "\(RedemptionStatus.OutOfStock.rawValue)"
//            )
//        case .ReadyForPickup:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "Ready For Pickup".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.ReadyForPickup.rawValue)"
//            )
//        case .VoucherUsed:
//            return PresentableRedemptionStatus(
//                title: redemption.isCashRedemption() ? "Processed".localized : "Voucher Used",
//                showcategory: true,
//                slug: "\(RedemptionStatus.VoucherUsed.rawValue)"
//            )
//        }
//    }
//
//    static func getAllPresentableRedemptionStatuses() ->[PresentableRedemptionStatus]{
//
//        return [
//            PresentableRedemptionStatus(
//                title: "Used".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.Used.rawValue)"
//            ),
//            PresentableRedemptionStatus(
//                title: "Not Used".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.RedeemedNotUsed.rawValue)"
//            ),
//            PresentableRedemptionStatus(
//                title: "Received".localized,
//                showcategory: true,
//                slug: "\(RedemptionStatus.Received.rawValue)"
//            )
//        ]
//    }
//}

enum RedemptionPendingActionType {
    case None
    case UseNow
}
class LeaderboardModel {
    
}

//struct LeaderboardModel : RawObjectProtocol {
//    private let rawRedemption : [String : Any]
//    var redemptionID : Int{
//        return rawRedemption["pk"] as? Int ?? -1
//    }
//
//    init(input : [String : Any]) {
//        self.rawRedemption = input
//    }
//
//    init(managedObject: NSManagedObject) {
//        self.rawRedemption = (managedObject as! ManagedRedemption).rawRedemption as! [String : Any]
//    }
//    var initModel : RFKRewardzCoordinatorInitModel! = nil
//    private var appCoordinator : RFKAppCoordinator{
//        return initModel.appCoordinator
//    }
//
//    @discardableResult func getManagedObject() -> NSManagedObject {
//        let managedRedemption: ManagedRedemption!
//        let fetchRequest : NSFetchRequest<ManagedRedemption> = ManagedRedemption.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "redemptionID = %d && redemptionID != -1", self.redemptionID)
//        let fetchedRedemptions = RFKCoreDataManager.sharedInstance.manager.fetchManagedObject(
//            type: ManagedRedemption.self,
//            fetchRequest: fetchRequest,
//            context: RFKCoreDataManager.sharedInstance.manager.privateQueueContext
//        )
//
////            CoreDataManager.sharedInstance.fetchManagedObject(
////            type: ManagedRedemption.self,
////            fetchRequest: fetchRequest,
////            context: CoreDataManager.sharedInstance.privateQueueContext
////        )
//        if let firstRedemption = fetchedRedemptions.fetchedObjects?.first{
//            print("<<<<<<<<<<<<<<<<update \(self.redemptionID)")
//            managedRedemption = firstRedemption
//        }else{
//            managedRedemption = RFKCoreDataManager.sharedInstance.manager.insertManagedObject(type: ManagedRedemption.self)
////            CoreDataManager.sharedInstance.insertManagedObject(type: ManagedRedemption.self)
//            managedRedemption.createdTimeStamp = Date()
//        }
//        managedRedemption.rawRedemption = rawRedemption as NSDictionary
//        managedRedemption.redemptionID = Int64(redemptionID)
//        return managedRedemption
//    }
//
//    func getRedemptionActionType() -> RedemptionPendingActionType {
//        switch getRedemptionStatus() {
//        case .RedeemedNotUsed, .Shipped, .ReadyForPickup:
//            return .UseNow
//        case .NA,.Received, .Expired, .InProcess, .OutOfStock, .VoucherUsed, .Used:
//            return .None
//        }
//    }
//
//    func getRedemptionStatus() -> RedemptionStatus{
//        if let status = rawRedemption["voucher_status"] as? Int{
//            return RedemptionStatus(rawValue: status) ?? .Used
//        }else{
//            return .Used
//        }
//    }
//
//    func getRewardName() -> String? {
//        return rawRedemption["reward_name"] as? String
//    }
//
//    func getValidity() -> String? {
//        if let createdDate = rawRedemption["reward_validity"] as? String{
//            let dateInFormate = createdDate.getdateFromStringFrom(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
//            return "\("Valid till".localized): \(dateInFormate.day) \(dateInFormate.monthName.prefix(3)) \(dateInFormate.year)"
//               }else{
//                   return ""
//               }
//    }
//
//    func getCreationDate() -> String? {
//        if let createdDate = rawRedemption["created"] as? String{
//            let dateInFormate = createdDate.getdateFromStringFrom(dateFormat: "yyyy-MM-dd'T'HH:mm:ss")
//            return "\(dateInFormate.day) \(dateInFormate.monthName.prefix(3))"
//        }else{
//            return ""
//        }
//    }
//
//    func getUserPoints() -> Double{
//        return rawRedemption["user_points"] as? Double ?? 0
//    }
//
//    func getRewardImage(_ networkRequestCoordinator: CFFNetworkRequestCoordinatorProtocol) -> URL? {
//        if let unwrappedDisplayImage = rawRedemption["reward_display_img_url"] as? String,
//           let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){
//            return URL(string: baseUrl + unwrappedDisplayImage)
//        }
//        else if let unwrappedDisplayImage = rawRedemption["display_img_url"] as? String,
//                let baseUrl = networkRequestCoordinator.getBaseUrlProvider().baseURLString(){//in case of use now this key changes
//            return URL(string: baseUrl + unwrappedDisplayImage)
//        }
//        else{
//            return nil
//        }
//    }
//
//    func getRewardCategoryType() -> RewardCategoryType? {
//        if let rewardCategory = rawRedemption["reward_category"] as? String{
//            return RewardCategoryType(rawValue: rewardCategory)
//        }else{
//            return nil
//        }
//    }
//
//    func isPhysicalDeliveryType() -> Bool {
//        if let redeptionType = rawRedemption["redemption_type"] as? String{
//            return redeptionType.lowercased() == "physical_delivery" ? true : false
//        }
//        return false
//    }
//
//    func isRewardPhysicalProductType() -> Bool {
//        if let redeptionType = rawRedemption["redemption_type"] as? String{
//            return redeptionType.lowercased() == "physical_product" ? true : false
//        }
//        return false
//    }
//
//    func isPhysicalRewardType() -> Bool {
//        if isPhysicalDeliveryType() || isRewardPhysicalProductType() {
//            return true
//        }
//        return false
//    }
//
//    func getRewardDetailObject() -> RewardsDetailObject {
//        return RewardsDetailObject(input: rawRedemption)!
//    }
//
//    func getPresentableQuantity() -> String  {
//        if let rewardCategory = getRewardCategoryType(),
//        rewardCategory == .PhysicalVoucher{
//            return "\("Quantity".localized): \(rawRedemption["quantity"] as? Int ?? 0)"
//        }else{
//            return ""
//        }
//
//    }
//
//    func getPresentablePoint() -> String?  {
//        if let rewardPoint = rawRedemption["reward_points"] as? Double{
//            let points = localizePoints(points: rewardPoint)
//            if rewardPoint != 0{
//                return "\(points)"
//            }
//        }
//        if let rewardCategory = getRewardCategoryType(),
//            rewardCategory == .Discount{
//            return getRewardDetailObject().getDescription()
//        }
//        return nil
//    }
//
//    func getDecimalValue(value : Double) -> String {
//        let decimalPointEnabled = UserDefaults.standard.value(forKey: "isDecimalPointsEnabled") as? Bool ?? false
//        if !decimalPointEnabled {
//            return String(format: "%.0f", value)
//        }
//        return String(format: "%.2f", value)
//    }
//
//    func localizePoints(points: Double) -> String {
//        if points > 1 || points < -1{
//              return "\(getDecimalValue(value: points)) \("Ptss".localized)"
//          }else {
//              return "\(getDecimalValue(value: points)) \("Pt".localized)\(points == 1 ? "" : "s".localized)"
//          }
//    }
//
//    func isCashRedemption() -> Bool {
//        if let redeptionType = rawRedemption["redemption_type"] as? String{
//            return redeptionType.lowercased() == "cash"
//        }
//        return false
//    }
//
//    func isPhysicalProductType() -> Bool {
//        if let redeptionType = rawRedemption["redemption_type"] as? String{
//            return redeptionType.lowercased() == "physical_product"
//        }
//        return false
//    }
//
//    func getDeliveryState(redemption : Redemption) -> String {
//        if redemption.getRedemptionStatus() == .Used ||
//            redemption.getRedemptionStatus() == .RedeemedNotUsed{
//            return "Order placed".localized
//        }else{
//            return redemption.getRedemptionStatus().getPresentableRedemptionStatus(redemption: redemption).title
//        }
//    }
//
//    func hideAcknowledgementForPhysicalProduct(redemption : Redemption) -> Bool {
//        if isPhysicalProductType() {
//            return redemption.getRedemptionStatus() == .RedeemedNotUsed ? true : false
//        }
//        return false
//    }
//}

//enum RewardCategoryType: String{
//    case EVoucher = "e-voucher"
//    case Discount = "discount"
//    case PhysicalVoucher = "physical-voucher"
//}

