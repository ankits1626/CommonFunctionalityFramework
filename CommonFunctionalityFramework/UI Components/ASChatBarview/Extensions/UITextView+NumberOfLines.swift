//
//  UITextView+NumberOfLines.swift
//  Vyn
//
//  Created by ankit on 26/06/19.
//  Copyright © 2019 humanLearning. All rights reserved.
//

import UIKit

extension UITextView{
    func getNumberOfLines() -> Int {
        let layoutManager:NSLayoutManager = self.layoutManager
        let numberOfGlyphs = layoutManager.numberOfGlyphs
        var numberOfLines = 0
        var index = 0
        var lineRange:NSRange = NSRange()
        while (index < numberOfGlyphs) {
            layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            index = NSMaxRange(lineRange);
            numberOfLines = numberOfLines + 1
        }
        return numberOfLines
    }
}
