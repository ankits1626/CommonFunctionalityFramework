//
//  FeedOrganisationListManager.swift
//  CommonFunctionalityFramework
//
//  Created by Ankit on 21/07/22.
//  Copyright © 2022 Rewardz. All rights reserved.
//

import Foundation
import UIKit
import RewardzCommonComponents

struct FeedOrganisationListManagerInitModel {
    weak var dataManager: FeedOrganisationDataManager?
    weak var tableView: UITableView?
    var recordSelectedCompletion : () -> Void
}


class FeedOrganisationListManager : NSObject{
    private let initModel: FeedOrganisationListManagerInitModel
    private let cellIdentifier = "FeedOrganisationTableViewCell"
    private let headerIdentifier = "FeedOrgaisationTableViewHeader"
    
    private var collapsedSections = Set<Int>()
    
    init(_ initModel: FeedOrganisationListManagerInitModel){
        self.initModel = initModel
        super.init()
        self.setupTableView()
    }
    
    func reset(){
        self.collapsedSections = Set<Int>()
    }
    
    func loadListAfterDataFetch(){
        initModel.tableView?.reloadData()
    }
}

extension FeedOrganisationListManager{
    
    private func setupTableView(){
        initModel.tableView?.register(
            UINib(
                nibName: cellIdentifier,
                bundle: Bundle(for: FeedOrganisationListManager.self)
            ),
            forCellReuseIdentifier: cellIdentifier
        )
        initModel.tableView?.register(
            UINib(
                nibName: headerIdentifier,
                bundle: Bundle(for: FeedOrganisationListManager.self)
            ),
            forHeaderFooterViewReuseIdentifier: headerIdentifier
        )
        initModel.tableView?.dataSource = self
        initModel.tableView?.delegate = self
//        if #available(iOS 15.0, *) {
//            initModel.tableView?.sectionHeaderTopPadding = 0
//        } else {
//            // Fallback on earlier versions
//        }
    }
    
}

extension FeedOrganisationListManager : UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return initModel.dataManager?.getOrganisations().count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.collapsedSections.contains(section) {
                return 0
        }else{
            
            return initModel.dataManager?.getOrganisations()[section].departments.filter{$0.isDisplayable}.count ?? 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
//        configureRank(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureDepartmentRow(cell: cell as! FeedOrganisationTableViewCell, indexpath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header =  tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier)
        return header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        configureOrganisationHeader(header: view as! FeedOrgaisationTableViewHeader, section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        userSelectionEvent(leaderboardUser(indexPath: indexPath))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
}

extension FeedOrganisationListManager{
    private func configureOrganisationHeader(header: FeedOrgaisationTableViewHeader, section: Int){
        header.expandCollapseBtn?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
            [weak self] in
            self?.toggleSection(section: section)
        })
        let organisation = initModel.dataManager!.getOrganisations()[section]
        header.organisationLbl?.text = organisation.displayName
        header.organisationLbl?.font = .Body2
        header.selectionDetailLbl?.font = .Body1
        header.organisationLbl?.textColor = .getTitleTextColor()
        header.headerContainer?.backgroundColor = .guidenceViewBackgroundColor
        header.headerContainer?.layer.cornerRadius = 4
        header.headerContainer?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        let image = UIImage(
            named: collapsedSections.contains(section) ? "cff_expand" : "cff_collapse",
            in: Bundle(for: PostEditorViewController.self),
            compatibleWith: nil
        )
        
        header.expandCollapseBtn?.setImage(
            image ,
            for: .normal
        )
        if let unwrappedDataManager = initModel.dataManager{
            if (unwrappedDataManager.checkIfOrganisationIsSelected(organisation)){
                header.checkBox.isChecked = true
            }else{
                header.checkBox.isChecked = false
            }
        }
        
        header.checkBox.toggleCheckBoxSelectionCompletion = {[weak self] in
            if let unwrappedSelf = self{
                unwrappedSelf.initModel.dataManager?.toggleOrganisationSelection(
                    organisation,
                    {
                        unwrappedSelf.initModel.tableView?.reloadSections(
                            IndexSet(integer: section),
                            with: .none
                        )
                        unwrappedSelf.initModel.recordSelectedCompletion()
                    })
//                unwrappedSelf.initModel.dataManager?.toggleOrganisationSelection(section)
//                unwrappedSelf.initModel.tableView?.reloadSections(IndexSet(integer: section), with: .none)
            }
        }
        
        header.selectionDetailLbl?.text = initModel.dataManager?.getSelectionDetails(organisation)
        

    }
    
    private func configureDepartmentRow(cell: FeedOrganisationTableViewCell, indexpath: IndexPath){
        
        let department = initModel.dataManager!.getOrganisations()[indexpath.section].departments.filter{$0.isDisplayable}[indexpath.row]
        cell.departmentLbl?.text = department.getDisplayName()
        cell.departmentLbl?.font = .Body2
        cell.departmentLbl?.textColor = .getTitleTextColor()
        cell.rowContainer?.addBorders(
            edges: isLastDepartment(indexpath)  ?  [.left, .right, .bottom] : [.left, .right],
            color: .guidenceViewBackgroundColor,
            inset: 0,
            thickness: 1
        )
        if isLastDepartment(indexpath){
            cell.cellSeperator?.backgroundColor = .clear
        }else{
            cell.cellSeperator?.backgroundColor = .guidenceViewBackgroundColor
        }
        
        if let unwrappedDataManager = initModel.dataManager{
            if (unwrappedDataManager.checkIfDepartmentIsSelected(department)){
                cell.checkBox.isChecked = true
            }else{
                cell.checkBox.isChecked = false
            }
        }
        
        cell.checkBox.toggleCheckBoxSelectionCompletion = {[weak self] in
            if let unwrappedSelf = self{
                unwrappedSelf.initModel.dataManager?.toggleDepartmentSelection(
                    department,
                    {
                        unwrappedSelf.initModel.tableView?.reloadSections(IndexSet(integer: indexpath.section), with: .none)
                        unwrappedSelf.initModel.recordSelectedCompletion()
                    })
                
            }
        }
    
    }
    
    private func isLastDepartment(_ indexpath : IndexPath) -> Bool{
        return (initModel.dataManager!.getOrganisations()[indexpath.section].departments.count - 1) == indexpath.row
    }
}

extension FeedOrganisationListManager{
    
    private func toggleSection( section: Int){
        let rows : Int = initModel.dataManager?.getOrganisations()[section].departments.filter{$0.isDisplayable}.count ?? 0
        if self.collapsedSections.contains(section) {
            self.collapsedSections.remove(section)
            if rows > 0{
                initModel.tableView?.insertRows(at: indexPathsForSection(section), with: .fade)
            }
            
        } else {
            self.collapsedSections.insert(section)
            
            if rows > 0{
                initModel.tableView?.deleteRows(at: indexPathsForSection(section), with: .fade)
            }
            
        }
        initModel.tableView?.reloadSections(IndexSet(integer: section), with: .none)
    }
    
    private func indexPathsForSection(_ section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let departments = initModel.dataManager!.getOrganisations()[section].departments
        for row in 0..<departments.count {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        return indexPaths
    }
}
