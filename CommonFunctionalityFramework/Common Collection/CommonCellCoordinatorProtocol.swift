//
//  CommonCellCoordinatorProtocol.swift
//  CommonFunctionalityFramework
//
//  Created by Rewardz on 03/03/20.
//  Copyright © 2020 Rewardz. All rights reserved.
//

import UIKit

protocol CommonCellCoordinatorDataSource : class {
    func getNumberOfItems() ->Int
    //func getItem<Item>(indexpath: IndexPath) -> Item?
    func getItemAt<Item>(index: Int) -> Item?
}

protocol CommonCollectionTypeProtocol : class{
    init(containedCollection: UIView) throws
    func registerCollectionForCell(type : CommomCollectionCellTypeProtocol) throws
    func dequeueCell(identifier:String, indexpath: IndexPath) -> CommonCollectionCellProtocol
}

protocol CommonCollectionCellProtocol : class{
    var cellType : CommomCollectionCellTypeProtocol {get}
}

class CommonCellCoordinatorBaseInputModel{
    weak var collectionType: CommonCollectionTypeProtocol!
    weak var datasource : CommonCellCoordinatorDataSource!
    var cellType : CommomCollectionCellTypeProtocol
    init(collectionType : CommonCollectionTypeProtocol, cellType:CommomCollectionCellTypeProtocol, datasource : CommonCellCoordinatorDataSource) {
        self.collectionType = collectionType
        self.datasource = datasource
        self.cellType = cellType
    }
}

class CommonCellCoordinatorCellDequeueInputModel: CommonCellCoordinatorBaseInputModel {
    var indexpath: IndexPath
    init(indexpath: IndexPath, collectionType : CommonCollectionTypeProtocol, cellType:CommomCollectionCellTypeProtocol, datasource: CommonCellCoordinatorDataSource) {
        self.indexpath = indexpath
        super.init(
            collectionType: collectionType,
            cellType: cellType,
            datasource: datasource
        )
    }
}

class CommonCellCoordinatorCellConfigurationInputModel: CommonCellCoordinatorCellDequeueInputModel {
    weak var cell: CommonCollectionCellProtocol!
    weak var eventListener: CommonCellCoordinatorDelegate!
    
    init(cell: CommonCollectionCellProtocol,eventListener: CommonCellCoordinatorDelegate, collectionType : CommonCollectionTypeProtocol,cellType:CommomCollectionCellTypeProtocol, datasource : CommonCellCoordinatorDataSource, indexpath : IndexPath) {
        self.cell = cell
        self.eventListener = eventListener
        super.init(
            indexpath: indexpath,
            collectionType: collectionType,
            cellType: cellType,
            datasource: datasource
        )
    }
}

protocol CommonCellCoordinatorDelegate : class {
    
}

protocol CommonCellCoordinatorProtocol {
    //func registerCollectionToRespectiveCell(_ inputModel: CommonCellCoordinatorBaseInputModel) throws
    func getCell(_ inputModel: CommonCellCoordinatorCellDequeueInputModel) -> CommonCollectionCellProtocol
    func configureCell(_ inputModel: CommonCellCoordinatorCellConfigurationInputModel) throws
    func getSizeOfCell(_ inputModel: CommonCellCoordinatorBaseInputModel) -> CGSize
}

protocol CommonCellTypeMapperProtocol {
    init(datasource : CommonCellCoordinatorDataSource)
    func getCellTypeIdentifier(indexpath: IndexPath) -> CommomCollectionCellTypeProtocol
    func getNumberOfRowsInSection(section: Int) -> Int
}

protocol CommomCollectionCellTypeProtocol {
    var cellTypeIdentifier : String {get}
    var cellNib : UINib? {get}
    func getCommonCellCoordinator() -> CommonCellCoordinatorProtocol
}

struct CommonCollectionCellFactoryInputModel {
    weak var delegate: CommonCellCoordinatorDelegate!
    var collectionType : CommonCollectionTypeProtocol!
    weak var datasource: CommonCellCoordinatorDataSource!
    var cellTypeMapper: CommonCellTypeMapperProtocol
}

protocol ComonCollectionContainerProtocol {
    var feedsCellFactory: CommonCellFactory{get}
}
