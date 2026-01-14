//
//  DiffDisplayRow.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public enum DiffDisplayRow: Sendable, Equatable {
    case row(DiffRow)

    /// Collapsed unchanged section (equal rows) from the original rows.
    /// - range: hidden rows index range in original `DiffRow[]` (half-open)
    case omitted(range: Range<Int>, oldCount: Int, newCount: Int)
}
