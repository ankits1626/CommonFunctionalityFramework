//
//  TopGetterListFilterCoordinator.swift
//  CommonFunctionalityFramework
//
//  Created by Suyesh Kandpal on 11/07/23.
//  Copyright © 2023 Rewardz. All rights reserved.
//

import Foundation

struct FilterSelectionResult {
    var selectedFilterOptionsIndicies = [Int]()
    var selectedSortOption = [Int]()
}

struct TopGettersFilterOption : Equatable {
    var displayName : String
    var slug : String
}

protocol TopGettersFilterCoordinatorDelegate : AnyObject {
    func manageItemSelectionToggle(_ selectedIndex : Int?, delectedIndex : Int?, filterSection : TopGettersFilterSection)
}

class TopGettersFilterCoordinator {
    let recogitionOptions = [
        TopGettersFilterOption(displayName: "Given", slug: "given"),
        TopGettersFilterOption(displayName: "Received", slug: "received"),
    ]
    
    let heroOptions = [
        TopGettersFilterOption(displayName: "Monthly", slug: "monthly"),
        TopGettersFilterOption(displayName: "Overall", slug: "overall"),
    ]
    
    var selectedRecognitionOptionsIndex = [Int]()
    var selectedSortOption = [Int]()
    var selectedRecognitionData : TopGettersFilterOption?
    var selectedHeroData : TopGettersFilterOption?
    weak var delegate : TopGettersFilterCoordinatorDelegate?
    private var previouslySelectedFilter : FilterSelectionResult?

    var isRecognitionExpanded : Bool = false
    var isHeroExpanded : Bool = false
    func restoreFilterAndSortOptions() {
        if let unwrappedPreviouslySelectedFilter = previouslySelectedFilter{
            selectedRecognitionOptionsIndex = unwrappedPreviouslySelectedFilter.selectedFilterOptionsIndicies
            selectedSortOption = unwrappedPreviouslySelectedFilter.selectedSortOption
        }else{
            selectedRecognitionOptionsIndex = [Int]()
            selectedSortOption = [Int]()
        }
    }
    
    func isRecognitionFilterOptionSelected(_ index: Int) -> Bool {
        return selectedRecognitionOptionsIndex.contains(index)
    }
    
    func isHeroOptionSelected(_ index : Int) -> Bool {
        return selectedSortOption.contains(index)
    }
    
    func clearFilters(){
        selectedRecognitionOptionsIndex = [Int]()
        selectedSortOption = [Int]()
        self.selectedRecognitionData = nil
        self.selectedHeroData = nil
        delegate?.manageItemSelectionToggle(nil, delectedIndex: nil, filterSection: .RecognitionType)
    }
    
    func toggleSelection(filterSection : TopGettersFilterSection, index: Int) {
        switch filterSection {
        case .RecognitionType:
            toggleRecognitionOptionSelection(index)
        case .HeroFilter:
            toggleHeroOptionSelection(index)
        case .HeroFilterSeparator, .RecognitionTypeSeparator:
            break
        }
    }
    
    private func toggleRecognitionOptionSelection(_ index: Int){
        selectedRecognitionOptionsIndex.removeAll()
        selectedRecognitionOptionsIndex.append(index)
        selectedRecognitionData = recogitionOptions[index]
        delegate?.manageItemSelectionToggle(index, delectedIndex: nil, filterSection: .RecognitionType)
    }
    
    private func toggleHeroOptionSelection(_ index: Int){
        selectedSortOption.removeAll()
        selectedSortOption.append(index)
        selectedHeroData = heroOptions[index]
        delegate?.manageItemSelectionToggle(index, delectedIndex: nil, filterSection: .HeroFilter)
    }
    
    func isFilterAndSortOptionMutated() -> Bool {
        if let _ = previouslySelectedFilter{
            return true
        }else{
            return (!selectedSortOption.isEmpty) || (!selectedRecognitionOptionsIndex.isEmpty)
        }
    }
        
    func saveFilterResult() {
        previouslySelectedFilter = FilterSelectionResult(
            selectedFilterOptionsIndicies: selectedRecognitionOptionsIndex,
            selectedSortOption: selectedSortOption
        )
    }
}

