//
//  DiffResult.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public struct DiffResult: Sendable, Equatable {
    public let rows: [DiffRow]

    public init(rows: [DiffRow]) {
        self.rows = rows
    }
}
