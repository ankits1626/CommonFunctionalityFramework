//
//  CommonCellFactory.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 04/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

struct CommonCellFactoryError {
    static let UndIdentifiedTypeError = NSError(
        domain: "com.rewardz.EventDetailCellTypeError",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "Unidentified cell type."]
    )
}

class CommonCellFactory {
    private var cachedCoordinators = [String : CommonCellCoordinatorProtocol]()
    private let inputModel : CommonCollectionCellFactoryInputModel
    
    init(_ input : CommonCollectionCellFactoryInputModel) {
        inputModel = input
    }
    
    func registerCollectionFactory(types : [CommomCollectionCellTypeProtocol]) throws {
        try types.forEach { (aCellType) in
            try self.inputModel.collectionType.registerCollectionForCell(type: aCellType)
        }
    }
    
    func getNuberOfRows(section : Int) -> Int {
        return inputModel.cellTypeMapper.getNumberOfRowsInSection(section: section)
    }
    
    
    func getCell(_ indexpath: IndexPath) throws -> CommonCollectionCellProtocol? {
        //NOTE: We cant move this to cell factory because there can be few cells which needs to provide the values before returning the cell so that height calculation can work properly
        
        let cellType : CommomCollectionCellTypeProtocol = inputModel.cellTypeMapper.getCellTypeIdentifier(indexpath: indexpath)
        return getCachedCoordinator(
            type: cellType).getCell(
            CommonCellCoordinatorCellDequeueInputModel(
                indexpath: indexpath,
                collectionType: inputModel.collectionType,
                cellType: cellType,
                datasource: inputModel.datasource
            )
        )
    }
    
    func configureCommonCollectionCell(_ cell : CommonCollectionCellProtocol, indexPath: IndexPath) throws{
        try getCachedCoordinator(type: cell.cellType).configureCell(
            CommonCellCoordinatorCellConfigurationInputModel(
                cell: cell,
                eventListener: inputModel.delegate,
                collectionType: inputModel.collectionType,
                cellType: cell.cellType,
                datasource: inputModel.datasource,
                indexpath: indexPath
            )
        )
    }
    
    func getHeightForRewardDetailCell(indexPath: IndexPath, type : CommomCollectionCellTypeProtocol) throws -> CGSize {
        return getCachedCoordinator(type: type).getSizeOfCell(
            CommonCellCoordinatorBaseInputModel(
                collectionType: inputModel.collectionType,
                cellType: type,
                datasource: inputModel.datasource
            )
        )
    }
    
    private func getCachedCoordinator(type : CommomCollectionCellTypeProtocol) -> CommonCellCoordinatorProtocol{
        if let unwrappedCoordinator = cachedCoordinators[type.cellTypeIdentifier]{
            return unwrappedCoordinator
        }else{
            cachedCoordinators[type.cellTypeIdentifier] = type.getCommonCellCoordinator()
            return type.getCommonCellCoordinator()
        }
    }
}
