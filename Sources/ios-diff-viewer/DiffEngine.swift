//
//  DiffEngine.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public enum DiffEngine {
    public static func diff(old: String, new: String) -> DiffResult {
        let changes = LineDiffEngine.diffLines(old: old, new: new)
        let rows = RowsBuilder.build(from: changes)
        return DiffResult(rows: rows)
    }
}
