//
//  TopGettersFilterViewController.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import UIKit
import RewardzCommonComponents

protocol TopGettersFilterDelegate : AnyObject{
    func finishedFilterSelection(selectedRecognitionType : TopGettersFilterOption?,selectedRecognitionIndex : [Int]?, selectedHeroType : TopGettersFilterOption?,selectedHeroIndex : [Int]?)
}

class TopGettersFilterViewController: UIViewController {

    @IBOutlet private weak var filterLabel: UILabel?
    @IBOutlet private weak var applyButton: UIButton?
    @IBOutlet private weak var collectionViewContainer: UIView?
    @IBOutlet private weak var navigationViewConatiner: UIView?
    @IBOutlet private weak var filterCollection: UICollectionView?
    
    private let loader = MFLoader()
    var searchTextField: UITextField!
    private weak var filterCoordinator : TopGettersFilterCoordinator?
    private weak var delegate : TopGettersFilterDelegate?
    @IBOutlet weak var emptyImageHeightConstraints : NSLayoutConstraint?
    @IBOutlet weak var emptyImageView : UIImageView?
    @IBOutlet weak var resetButton : UIButton?
    @IBOutlet weak var filterByTitle : UILabel?
    
    
    init(filterCoordinator : TopGettersFilterCoordinator, delegate:TopGettersFilterDelegate) {
        self.filterCoordinator = filterCoordinator
        self.delegate = delegate
        super.init(nibName: "TopGettersFilterViewController", bundle: Bundle(for: TopGettersFilterViewController.self))
        self.filterCoordinator?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.filterByTitle?.text = "Filter by".localized
        resetButton?.setTitle("Reset all".localized, for: .normal)
        filterLabel?.text = "Filters".localized
        self.applyButton?.setTitle("Apply".localized, for: .normal)
        navigationViewConatiner?.backgroundColor = UIColor.getControlColor()
        self.view.backgroundColor = UIColor.getControlColor()
        fetchFilterOptions()
        setupCollectionView()
        configureApplyButton()
        resetButton?.isHidden = true
        applyButton?.isHidden = true
    }
    
    private func configureApplyButton(){
        applyButton?.backgroundColor = .getControlColor()
        applyButton?.curvedCornerControl()
        applyButton?.isHidden = !filterCoordinator!.isFilterAndSortOptionMutated()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionViewContainer?.roundCorners(corners: [.topLeft,.topRight], radius: 16)
    }
    
    private func fetchFilterOptions(){
//        filterCoordinator?.restoreFilterAndSortOptions()
        self.filterCollection?.reloadData()
    }
    
    private func setupCollectionView(){
        let layout = LeftCustomFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = CGSize(width: view.frame.size.width, height: 50)
        filterCollection?.collectionViewLayout = layout
        filterCollection?.contentInset = UIEdgeInsets(top: 5, left: 13.5, bottom: 5, right: 5)
        TopGettersFilterSection.allCases.forEach { (aSection) in
            aSection.getAdapter(filterCoordinator!).registerCellAndHeader(filterCollection)
        }
        filterCollection?.dataSource = self
        filterCollection?.delegate = self
        filterCollection?.backgroundColor = UIColor.clear
        filterCollection?.reloadData()
    }
    
    private func hideLoader(){
        loader.hideActivityIndicator(view)
    }
    
    @IBAction private func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func applyFilter(){
        delegate?.finishedFilterSelection(selectedRecognitionType: filterCoordinator?.selectedRecognitionData, selectedRecognitionIndex: filterCoordinator?.selectedRecognitionOptionsIndex, selectedHeroType: filterCoordinator?.selectedHeroData, selectedHeroIndex: filterCoordinator?.selectedSortOption)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearAllSearched(sender : UIButton) {
        if let filterC = self.filterCoordinator {
            filterC.clearFilters()
            filterC.isHeroExpanded = true
            filterC.isRecognitionExpanded = true
            delegate?.finishedFilterSelection(selectedRecognitionType: nil, selectedRecognitionIndex: nil, selectedHeroType: nil, selectedHeroIndex: nil)
        }
        navigationController?.popViewController(animated: true)
    }
}

extension TopGettersFilterViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let cordinator = filterCoordinator {
            self.resetButton?.isHidden = cordinator.isHeroExpanded || cordinator.isRecognitionExpanded ? false : true
            self.applyButton?.isHidden = cordinator.isHeroExpanded || cordinator.isRecognitionExpanded ? false : true
            emptyImageHeightConstraints?.constant = cordinator.isHeroExpanded || cordinator.isRecognitionExpanded ? 48 : 241
        }
        return TopGettersFilterSection(rawValue: section)!.getAdapter(filterCoordinator!).getNumberOfItemsInSection()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return TopGettersFilterSection(rawValue: indexPath.section)!.getAdapter(filterCoordinator!).getCell(collectionView, indexpath: indexPath)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return TopGettersFilterSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return TopGettersFilterSection(rawValue: indexPath.section)!.getAdapter(filterCoordinator!).getHeader(
            collectionView,
            viewForSupplementaryElementOfKind: kind,
            at: indexPath
        )
    }
}

extension TopGettersFilterViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return TopGettersFilterSection(rawValue: section)!.getAdapter(filterCoordinator!).heightOfHeader(collectionView)
    }
}
extension TopGettersFilterViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        filterCoordinator?.toggleSelection(filterSection: TopGettersFilterSection(rawValue: indexPath.section)!, index: indexPath.row)
    }
}

extension TopGettersFilterViewController : TopGettersFilterCoordinatorDelegate{
    func manageItemSelectionToggle(_ selectedIndex: Int?, delectedIndex: Int?, filterSection: TopGettersFilterSection) {
        filterCollection?.reloadData()
        configureApplyButton()
    }
}


