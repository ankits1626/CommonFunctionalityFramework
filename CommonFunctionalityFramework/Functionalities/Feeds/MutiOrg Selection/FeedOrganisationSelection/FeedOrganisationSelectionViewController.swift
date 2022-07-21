//
//  FeedOrganisationSelectionViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 20/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit


struct FeedOrganisationSelectionInitModel{
    weak var requestCoordinator: CFFNetworkRequestCoordinatorProtocol?
}

/**
 This view controller will aid to  show lisk or organisations which user can select to publish the post/poll
 github reference:https://github.com/rewardz/skor-ios/issues/318
 design reference:https://app.zeplin.io/project/5e73634bba9dfc0445f0510f/screen/62d665ffb5637612c9081dbf
 */
class FeedOrganisationSelectionViewController: UIViewController {
    var containerTopBarModel : GenericContainerTopBarModel?{
        didSet{
            setupContainerTopbar()
        }
    }
    private let initModel : FeedOrganisationSelectionInitModel
    
    @IBOutlet private weak var proceedButton : UIButton?
    @IBOutlet private weak var proceedButtonContainerHeight : NSLayoutConstraint?
    @IBOutlet private weak var searchTextField: UITextField?
    
    private func setupContainerTopbar(){
        containerTopBarModel?.title?.text = "Select Organisation".localized.uppercased()
    }
    
    init(_ initModel : FeedOrganisationSelectionInitModel) {
        self.initModel = initModel
        super.init(nibName: "FeedOrganisationSelectionViewController", bundle: Bundle(for: FeedOrganisationSelectionViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnViewDidLoad()
    }

}

extension FeedOrganisationSelectionViewController{
    private func setupOnViewDidLoad(){
        configureSearchBar()
        configureProceedButton()
    }
    
    private func configureSearchBar(){
        searchTextField?.backgroundColor = UIColor(red: 249, green: 249, blue: 251)
        searchTextField?.placeholder = "🔍 " + "search orginisation".localized.lowercased()
    }
    
    private func configureProceedButton(){
        
    }
}
