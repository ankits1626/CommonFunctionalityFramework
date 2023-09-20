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
        initModel.dataManager?.selectedDepartment.removeAll()
        initModel.dataManager?.selectedOrganisation.removeAll()
        initModel.dataManager?.selectedJobFamily.removeAll()
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
        initModel.tableView?.separatorStyle = .none
        initModel.tableView?.dataSource = self
        initModel.tableView?.delegate = self
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
        if self.collapsedSections.contains(section) {
            return 55
        }else{
            if let unwrappedData = initModel.dataManager {
                return !unwrappedData.isDepartmentEnabled(section: section) && !unwrappedData.isJobFamilyEnabled(section: section) ? 55 : 125
            }
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        userSelectionEvent(leaderboardUser(indexPath: indexPath))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
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
        header.organisationLbl?.textColor = .getTitleTextColor()
        header.selectAllStackView?.isHidden = self.collapsedSections.contains(section) ? true : false
        header.selectAllDepartmentView?.isHidden = !initModel.dataManager!.isDepartmentEnabled(section: section)
        header.selectJobFamilyContainerView?.isHidden = !initModel.dataManager!.isJobFamilyEnabled(section: section)
        header.selectAllDepartment?.curvedUIBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255), borderWidth: 1.0, cornerRadius: 8.0)
        header.selectJobFamilyContainerView?.curvedUIBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255), borderWidth: 1.0, cornerRadius: 8.0)
        
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
        
        header.selectAllDepartment?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
            [weak self] in
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
            }
        })
        
        header.selectAllJobFamiles?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
            [weak self] in
            if let unwrappedSelf = self{
                unwrappedSelf.initModel.dataManager?.toggleJobFamilySelection(
                    organisation,
                    {
                        unwrappedSelf.initModel.tableView?.reloadSections(
                            IndexSet(integer: section),
                            with: .none
                        )
                        unwrappedSelf.initModel.recordSelectedCompletion()
                    })
            }
        })
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
        cell.departmentCounts?.text = "\(department.isJobFamily ? department.getJobFamilyCount() : department.getDepartmentCount()) \("Members".localized)"
        cell.rowTypeStatusLabel?.text = department.isJobFamily ? "Job Family".localized : "Department".localized
        handleDepartmentCell(indexpath: indexpath, cell: cell)
        cell.rowTypeViewContainer?.backgroundColor = department.isJobFamily ? initModel.dataManager!.getJobFamilyBackgroundColor() : initModel.dataManager!.getDepartmentBackgroundColor()
        cell.itemListener?.handleControlEvent(event: .touchUpInside, buttonActionBlock: {
            [weak self] in
            if let unwrappedSelf = self{
                unwrappedSelf.initModel.dataManager?.toggleDepartmentSelection(
                    department,
                    {
                        unwrappedSelf.initModel.tableView?.reloadSections(IndexSet(integer: indexpath.section), with: .none)
                        unwrappedSelf.initModel.recordSelectedCompletion()
                    })

            }
        })
    }
    
    func handleDepartmentCell(indexpath: IndexPath,cell: FeedOrganisationTableViewCell) {
        let department = initModel.dataManager!.getOrganisations()[indexpath.section].departments.filter{$0.isDisplayable}[indexpath.row]
        if let unwrappedDataManager = initModel.dataManager{
            if (unwrappedDataManager.checkIfDepartmentIsSelected(department)) || (unwrappedDataManager.checkIfJobFamilyIsSelected(department)){
                cell.rowContainer?.backgroundColor = .getControlColor()
                cell.departmentLbl?.textColor = .white
                cell.rowTypeViewContainer?.backgroundColor = .getControlColor().withAlphaComponent(0.1)
                cell.rowTypeViewContainer?.curvedUIBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255,alpha: 0.1), borderWidth: 1.0, cornerRadius: 6.0)
                cell.rowTypeStatusLabel?.textColor = .white
            }else{
                cell.rowContainer?.backgroundColor = .white
                cell.departmentLbl?.textColor = UIColor(red: 21/255, green: 21/255, blue: 21/255)
                cell.rowTypeViewContainer?.backgroundColor = .white
                cell.rowTypeViewContainer?.curvedUIBorderedControl(borderColor: UIColor(red: 237, green: 240, blue: 255), borderWidth: 1.0, cornerRadius: 6.0)
                cell.rowTypeStatusLabel?.textColor = department.isJobFamily ? initModel.dataManager!.getJobFamilyTitleColor() : initModel.dataManager!.getDepartmentTitleColor()
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
            initModel.tableView?.insertRows(at: indexPathsForSection(section), with: .fade)
        } else {
            self.collapsedSections.insert(section)
            initModel.tableView?.deleteRows(at: indexPathsForSection(section), with: .fade)
        }
        initModel.tableView?.reloadSections(IndexSet(integer: section), with: .none)
    }
    
    private func indexPathsForSection(_ section: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        let departments = initModel.dataManager!.getOrganisations()[section].departments.filter{$0.isDisplayable}
        for row in 0..<departments.count {
            indexPaths.append(IndexPath(row: row, section: section))
        }
        return indexPaths
    }
}
