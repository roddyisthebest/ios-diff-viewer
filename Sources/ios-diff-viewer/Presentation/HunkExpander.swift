//
//  HunkExpander.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public enum HunkExpander {

    /// Expand a single omitted block at `displayIndex` if it is omitted.
    public static func expandOne(_ hunk: DiffHunk, at displayIndex: Int) -> DiffHunk {
        guard displayIndex >= 0, displayIndex < hunk.rows.count else { return hunk }
        guard case .omitted(let range, _, _) = hunk.rows[displayIndex] else { return hunk }

        var newDisplay = hunk.rows
        newDisplay.remove(at: displayIndex)

        let expanded = hunk.sourceRows[range].map(DiffDisplayRow.row)
        newDisplay.insert(contentsOf: expanded, at: displayIndex)

        return DiffHunk(sourceRows: hunk.sourceRows, rows: newDisplay)
    }

    /// Expand all omitted blocks.
    public static func expandAll(_ hunk: DiffHunk) -> DiffHunk {
        // If there are no omitted blocks, return as-is.
        guard hunk.rows.contains(where: { if case .omitted = $0 { return true } else { return false } }) else {
            return hunk
        }

        // Build a new display stream by replacing omitted blocks with the underlying source rows.
        var out: [DiffDisplayRow] = []
        out.reserveCapacity(hunk.sourceRows.count)

        for item in hunk.rows {
            switch item {
            case .row(let r):
                out.append(.row(r))
            case .omitted(let range, _, _):
                out.append(contentsOf: hunk.sourceRows[range].map(DiffDisplayRow.row))
            }
        }

        return DiffHunk(sourceRows: hunk.sourceRows, rows: out)
    }
}
