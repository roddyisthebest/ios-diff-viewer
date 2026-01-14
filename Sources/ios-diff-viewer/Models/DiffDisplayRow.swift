//
//  DiffDisplayRow.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public enum DiffDisplayRow: Sendable, Equatable {
    case row(DiffRow)

    /// Collapsed unchanged section (equal rows).
    /// oldCount/newCount are the number of lines hidden on each side.
    case omitted(oldCount: Int, newCount: Int)
}
