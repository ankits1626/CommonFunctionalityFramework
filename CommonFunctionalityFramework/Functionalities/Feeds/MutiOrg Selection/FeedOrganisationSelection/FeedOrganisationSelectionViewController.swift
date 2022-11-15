//
//  FeedOrganisationSelectionViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 20/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents


struct FeedOrganisationSelectionInitModel{
    weak var requestCoordinator: CFFNetworkRequestCoordinatorProtocol?
    var selectionModel: FeedOrganisationDepartmentSelectionModel?
    var selectionCompletionHandler : (_ selectionModel: FeedOrganisationDepartmentSelectionModel?, _ displayable: FeedOrganisationDepartmentSelectionDisplayModel) -> Void
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
    
    @IBOutlet private weak var topInfoLabel : UILabel?
    @IBOutlet private weak var proceedButton : UIButton?
    @IBOutlet private weak var proceedButtonContainerHeight : NSLayoutConstraint?
    @IBOutlet private weak var searchTextField: UITextField?
    @IBOutlet private weak var organisationListTableView: UITableView?
    @IBOutlet private weak var clearButton: UIButton?
    @IBOutlet private weak var clearButtonWidthConstraint: NSLayoutConstraint?
    
    private func setupContainerTopbar(){
        containerTopBarModel?.title?.text = "Select Orgs/Dept".localized.uppercased()
    }
    
    private lazy var dataManager: FeedOrganisationDataManager = {
        return FeedOrganisationDataManager(
            FeedOrganisationDataManagerInitModel(
                requestCoordinator: initModel.requestCoordinator,
                selectionModel: initModel.selectionModel
            )
        )
    }()
    
    lazy var listManager: FeedOrganisationListManager = {
        return FeedOrganisationListManager(
            FeedOrganisationListManagerInitModel(
                dataManager: dataManager,
                tableView: organisationListTableView,
                recordSelectedCompletion: { [weak self] in
                    self?.configureProceedButton()
                }
            )
        )
    }()
    
    init(_ initModel : FeedOrganisationSelectionInitModel) {
        self.initModel = initModel
        super.init(nibName: "FeedOrganisationSelectionViewController", bundle: Bundle(for: FeedOrganisationSelectionViewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("FeedOrganisationSelectionViewController init(coder:) has not been implemented")
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
        askDataManagerToFetchData()
        setupTopInfoLabel()
        toggleClearSearchButtonVisibility()
    }
    
    private func toggleClearSearchButtonVisibility(){
        if let unwrappedSearchText = searchTextField?.text,
           !unwrappedSearchText.isEmpty{
            clearButtonWidthConstraint?.constant = 70
        }else{
            clearButtonWidthConstraint?.constant = 0
        }
    }
    
    private func setupTopInfoLabel(){
        topInfoLabel?.font = .Caption1
        topInfoLabel?.textColor = .black35
    }
    
    private func configureSearchBar(){
        searchTextField?.backgroundColor = UIColor(red: 249, green: 249, blue: 251)
        searchTextField?.placeholder = "🔍 " + "search organisations/departments".localized.lowercased()
        searchTextField?.addTarget(
            self,
            action: #selector(performSearch),
            for: .editingDidEndOnExit
        )
        searchTextField?.addTarget(
            self,
            action: #selector(searchFieldDidChanged),
            for: .editingChanged
        )
    }
    
    private func configureProceedButton(){
        proceedButton?.backgroundColor = .getControlColor()
        proceedButtonContainerHeight?.constant = dataManager.checkIfAnyOrganisationOrDepartmentSelected() ? 52 : 0
    }
    
    private func askDataManagerToFetchData(){
        dataManager.fetchFeedOrganisations {error in
            DispatchQueue.main.async {[weak self] in
                if let unwrappedSelf = self{
                    if let unwrappedError = error{
                        ErrorDisplayer.showError(errorMsg: unwrappedError) { _ in}
                    }
                    unwrappedSelf.listManager.loadListAfterDataFetch()
                }
            }
        }
    }
}

extension FeedOrganisationSelectionViewController{
    @IBAction func proceedButtonTapped(){
        initModel.selectionCompletionHandler(
            dataManager.getSelectedOrganisationsAndDepartments(),
            dataManager.getSelectedOrganisationsAndDepartmentsDisplayable()
        )
    }
}

extension FeedOrganisationSelectionViewController{
    
    @IBAction private func clearSearch(){
        searchTextField?.text = nil
        toggleClearSearchButtonVisibility()
        performSearch()
    }
    
    @objc private func searchFieldDidChanged(){
        toggleClearSearchButtonVisibility()
    }
    
    @objc private func performSearch(){
        if let searchText = searchTextField?.text,
           !searchText.isEmpty{
            debugPrint("search \(searchText)")
            dataManager.updateSearchState(true)
            dataManager.performSearch(searchText) {[weak self] in
                self?.listManager.reset()
                self?.listManager.loadListAfterDataFetch()
            }
        }else{
            dataManager.updateSearchState(false)
            listManager.reset()
            listManager.loadListAfterDataFetch()
        }
        
    }
    
}
