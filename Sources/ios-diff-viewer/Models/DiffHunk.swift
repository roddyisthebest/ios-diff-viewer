//
//  DiffHunk.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public struct DiffHunk: Sendable, Equatable {
    /// Original full rows (unfolded).
    public let sourceRows: [DiffRow]

    /// Display stream (with omitted blocks).
    public let rows: [DiffDisplayRow]

    public init(sourceRows: [DiffRow], rows: [DiffDisplayRow]) {
        self.sourceRows = sourceRows
        self.rows = rows
    }
}
