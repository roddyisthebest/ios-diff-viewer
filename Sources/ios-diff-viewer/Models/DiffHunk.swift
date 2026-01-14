//
//  DiffHunk.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public struct DiffHunk: Sendable, Equatable {
    public let rows: [DiffDisplayRow]

    public init(rows: [DiffDisplayRow]) {
        self.rows = rows
    }
}
