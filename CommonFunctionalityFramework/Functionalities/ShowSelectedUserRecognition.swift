//
//  ShowSelectedUserRecognition.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 10/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit

public enum ShowSelectedUserTypeContainer : Int {
    case Given = 0
    case Received
}

class ShowSelectedUserRecognition: UIViewController{
    
    @IBOutlet weak var headerView : UIView?
    private weak var currentChildVC : UIViewController?
    @IBOutlet weak var holderParentViewContainer : UIView?
    @IBOutlet weak var recognitionSegmentView : UISegmentedControl?
    @IBOutlet private var segmentContainerView : UIView?
    @IBOutlet private var segmentParentView : UIView?
    var requestCoordinator: CFFNetworkRequestCoordinatorProtocol!
    var loader = MFLoader()
    var mediaFetcher: CFFMediaCoordinatorProtocol!
    var themeManager : CFFThemeManagerProtocol?
    var mainAppCoordinator : CFFMainAppInformationCoordinator?
    
    var feedTypePk : Int = 0
    var organisationPK : Int = 0
    var departmentPK : Int = 0
    var dateRangePK : Int = 0
    var coreValuePk : Int = 0
    var isCreationIconRequired : Bool = false
    var feedScreenType : ShowSelectedUserTypeContainer!
    var selectedContainer : ShowSelectedUserTypeContainer!{
        didSet{
            if oldValue != selectedContainer{
                changeContainerAsPerSelectedChoice()
            }
        }
    }
    
    override func viewDidLoad() {
        self.headerView?.backgroundColor = UIColor.getControlColor()
        self.view.backgroundColor = UIColor.getControlColor()
        setupContainerView()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if feedScreenType == nil {
            selectedContainer = .Given
        }else {
            self.recognitionSegmentView?.selectedSegmentIndex = feedScreenType.rawValue
            selectedContainer = feedScreenType
        }
    }
    
    private func setupContainerView() {
        segmentContainerView?.backgroundColor = UIColor.getControlColor()
        recognitionSegmentView?.addTarget(self, action: #selector(ShowSelectedUserRecognition.segmentValueChanged(_:)), for: .valueChanged)
        self.view.backgroundColor = UIColor.getControlColor()
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6),
                                   NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
        recognitionSegmentView?.setTitleTextAttributes(titleTextAttributes, for: .normal)
        recognitionSegmentView?.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentParentView?.backgroundColor = UIColor.getControlColor()
        recognitionSegmentView?.tintColor = UIColor.getControlColor()
        if #available(iOS 13.0, *) {
            recognitionSegmentView?.selectedSegmentTintColor = UIColor.getControlColor()
        } else {
            // Fallback on earlier versions
        }
        recognitionSegmentView?.backgroundColor = UIColor.getControlColor().lighter(by: 10)
    }
    
    @objc func segmentValueChanged(_ sender: UISegmentedControl) {
        selectedContainer = ShowSelectedUserTypeContainer(rawValue: sender.selectedSegmentIndex)!
    }
    
    private func changeContainerAsPerSelectedChoice() {
        removeExistingContainer()
        switch selectedContainer! {
        case .Given:
            showReceivedTab(type: "given")
        case .Received:
            showReceivedTab(type: "received")
        }
    }
    
    
    func showReceivedTab(type : String) {
        removeExistingContainer()
        addViewControllerToContainer(CommonFeedsCoordinator().getFeedsView(
            GetCommonFeedsViewModel(
                networkRequestCoordinator: requestCoordinator,
                mediaCoordinator: mediaFetcher,
                feedCoordinatorDelegate: self,
                themeManager: themeManager,
                mainAppCoordinator: mainAppCoordinator,
                selectedTabType: type, searchText: nil,
                _feedTypePk: self.feedTypePk,
                _organisationPK: self.organisationPK,
                _departmentPK: self.departmentPK,
                _dateRangePK: self.dateRangePK,
                _coreValuePk: self.coreValuePk,
                _isCreationButtonRequired: self.isCreationIconRequired,
                _hideTopLeaderboard: true,
                _isDesklessEnabled: false
            )
        ))
    }
    
    func showGivenTab() {
        removeExistingContainer()
    }
    
    private func addViewControllerToContainer(_ newVC : UIViewController){
        addChild(newVC)
        newVC.view.frame = holderParentViewContainer!.bounds
        holderParentViewContainer?.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        currentChildVC = newVC
    }
    
    private func removeExistingContainer(){
        currentChildVC?.willMove(toParent: nil)
        currentChildVC?.view.removeFromSuperview()
        currentChildVC?.removeFromParent()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ShowSelectedUserRecognition :  FeedsCommonCoordinatorDelegate {
    func showFeedDetail(_ detailViewController: UIViewController) {
        let feedDetailContainer = SelectedRecognitionDetailViewController(nibName: "SelectedRecognitionDetailViewController", bundle: Bundle(for: SelectedRecognitionDetailViewController.self))
        feedDetailContainer.feedDetailVC = detailViewController
        self.navigationController?.pushViewController(feedDetailContainer, animated: true)
    }
    
    func removeFeedDetail() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showComposer(_composer: UIViewController, completion: @escaping ((EditorContainerModel) -> Void)) {
        
    }
    
    func showPostLikeList(_ likeListVC: UIViewController, presentationOption: GenericContainerPresentationOption, completion: @escaping ((GenericContainerTopBarModel) -> Void)) {
        
    }
}
