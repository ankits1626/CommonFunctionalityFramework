//
//  AppreciationBottomSheet.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 21/08/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

enum AppreciationBottomSheetType: String{
    case Delete = "Delete"
    case ReportAbuse = "ReportAbuse"
}

protocol AppreciationBottomSheetTypeProtocol {
    func selectedFilterType(selectedType : AppreciationBottomSheetType, feedIdentifier : Int64)
}
class AppreciationBottomSheet: UIViewController {
    
    @IBOutlet private weak var deleteButton : UIButton?
    @IBOutlet private weak var reportButton : UIButton?
    @IBOutlet private weak var deleteButtonView : UIView?
    @IBOutlet private weak var reportButtonView : UIView?
    
    var feedIdentifier : Int64 = 0
    
    
    var isreportAbusedEnabled : Bool = false
    var isDeleteFlagEnabled : Bool = false
    var numberofElementsEnabled : Int = 0
    
    private lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    var bottomsheetdelegate : AppreciationBottomSheetTypeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        deleteButtonView?.isHidden = isDeleteFlagEnabled == true ? false : true
        reportButtonView?.isHidden = isreportAbusedEnabled == true ? false : true
        
        deleteButton?.setTitle("Delete".localized, for: .normal)
        reportButton?.setTitle("Report Abuse".localized, for: .normal)

    }
    
    private func setup() {
        view.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.roundCorners(corners: [.topLeft, .topRight], radius: 6.0)
    }
    
    func presentDrawer(numberofElementsEnabled : CGFloat) throws{
        if let topviewController : UIViewController = UIApplication.topViewController(){
            slideInTransitioningDelegate.direction = .bottom(height: numberofElementsEnabled < 3 ? 129 : 220.0)
            transitioningDelegate = slideInTransitioningDelegate
            modalPresentationStyle = .custom
            topviewController.present(self, animated: true, completion: nil)
        }else{
            throw NSError(
                domain: "com.rewardz.ReceiptsComposer",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to get top view controller"]
            )
        }
    }
}
extension AppreciationBottomSheet{
    
    @IBAction func deleteButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .Delete,feedIdentifier: self.feedIdentifier)
        }
    }
    
    @IBAction func reportButtonPressed(){
        dismiss(animated: true) {
            self.bottomsheetdelegate?.selectedFilterType(selectedType: .ReportAbuse,feedIdentifier: self.feedIdentifier)
        }
    }
}




