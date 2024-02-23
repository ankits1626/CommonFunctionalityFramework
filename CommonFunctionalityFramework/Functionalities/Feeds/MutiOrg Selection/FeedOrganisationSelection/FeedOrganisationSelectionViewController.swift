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
    weak var mainConatiner : CFFMainAppInformationCoordinator?
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
    
    @IBOutlet private weak var proceedButton : UIButton?
    @IBOutlet private weak var proceedButtonContainerHeight : NSLayoutConstraint?
    @IBOutlet private weak var searchTextField: UITextField?
    @IBOutlet private weak var organisationListTableView: UITableView?
    @IBOutlet private weak var clearButton: UIButton?
    @IBOutlet private weak var selectAllParentContainerView : UIView?
    @IBOutlet private weak var selectAllContainerView : UIView?
    @IBOutlet private weak var selectAllTitleLabel : UILabel?
    @IBOutlet private weak var selectAllSwitch : UISwitch?
    @IBOutlet private weak var filterByLabel : UILabel?
    
    private func setupContainerTopbar(){
        let nuhsMultiOrg = (self.initModel.mainConatiner?.isNuhsMultiOrgPostEnabled())! ? "Select Org/Dept/Job Family".localized : "Select Orgs/Dept".localized
        containerTopBarModel?.title?.text = nuhsMultiOrg
        selectAllParentContainerView?.isHidden = (self.initModel.mainConatiner?.isNuhsMultiOrgPostEnabled())! ? false : true
    }
    
    private lazy var dataManager: FeedOrganisationDataManager = {
        return FeedOrganisationDataManager(
            FeedOrganisationDataManagerInitModel(
                requestCoordinator: initModel.requestCoordinator,
                selectionModel: initModel.selectionModel,
                everyonNuhsSwitch: self.selectAllSwitch
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
                    self?.checkSwitchState()
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
        filterByLabel?.text = "Filter by".localized
        proceedButton?.setTitle("PROCEED".localized, for: .normal)
    }

}


extension FeedOrganisationSelectionViewController{
    private func setupOnViewDidLoad(){
        configureSearchBar()
        configureProceedButton()
        askDataManagerToFetchData()
        toggleClearSearchButtonVisibility()
        setupSelectAllSwitch()
    }
    
    private func toggleClearSearchButtonVisibility(){
        if let unwrappedSearchText = searchTextField?.text,
           !unwrappedSearchText.isEmpty{
            clearButton?.isHidden = false
        }else{
            clearButton?.isHidden = true
        }
    }
    
    private func configureSearchBar(){
        searchTextField?.backgroundColor = UIColor(red: 245, green: 248, blue: 255)
        searchTextField?.placeholder = " 🔍 " + "search organisations/departments".localized.lowercased()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchTextField?.roundCorners(corners: .allCorners, radius: 8.0)
        selectAllContainerView?.roundCorners(corners: .allCorners, radius: 8.0)
        proceedButton?.roundCorners(corners: .allCorners, radius: 8.0)
    }
    
    private func setupSelectAllSwitch() {
        selectAllSwitch?.onTintColor = UIColor.getControlColor()
        selectAllSwitch?.tintColor = UIColor.getControlColor()
        selectAllSwitch?.subviews[0].subviews[0].backgroundColor = UIColor(red: 171, green: 173, blue: 192)
    }
    
    private func configureProceedButton(){
        self.proceedButton?.backgroundColor = .getControlColor()
        self.proceedButton?.alpha = self.dataManager.checkIfAnyOrganisationOrDepartmentSelected() ? 1 : 0.5
        self.proceedButton?.isUserInteractionEnabled = self.dataManager.checkIfAnyOrganisationOrDepartmentSelected() ? true : false
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
    
    @IBAction func switchValueDidChange(_ sender: UISwitch) {
        if let unwrappedSwitch = selectAllSwitch,
           unwrappedSwitch.isOn{
            self.dataManager.selectedJobFamily = self.dataManager.selectedJobFamilyPk
            self.dataManager.selectedDepartment = self.dataManager.selectedDepartmentPk
            self.dataManager.selectedOrganisation = self.dataManager.selectedOrganisationPk
            listManager.loadListAfterDataFetch()
        }else {
            self.dataManager.selectedJobFamily = Set<Int>()
            self.dataManager.selectedDepartment = Set<Int>()
            self.dataManager.selectedOrganisation = Set<Int>()
            listManager.loadListAfterDataFetch()
        }
        configureProceedButton()
    }
    
    func checkSwitchState() {
        if self.dataManager.selectedOrganisation == self.dataManager.selectedOrganisationPk {
            selectAllSwitch?.isOn = true
        }else {
            selectAllSwitch?.isOn = false
        }
    }
}
