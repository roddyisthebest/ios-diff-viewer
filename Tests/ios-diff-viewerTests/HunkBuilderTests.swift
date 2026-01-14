//
//  HunkBuilderTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Testing
@testable import ios_diff_viewer

@Test
func hunkBuilder_folds_far_equals_and_keeps_context() {
    // Make a long file with one change in the middle
    let oldLines = (0..<30).map { "line-\($0)" }
    var newLines = oldLines
    newLines[15] = "line-15-modified"

    let old = oldLines.joined(separator: "\n")
    let new = newLines.joined(separator: "\n")

    let res = DiffEngine.diff(old: old, new: new)
    let hunk = HunkBuilder.build(from: res.rows, config: .init(context: 2, smallEqualRunThreshold: 1))

    // Should contain at least one omitted block
    #expect(hunk.rows.contains(where: {
        if case .omitted = $0 { return true }
        return false
    }))

    // Must contain the modify row
    #expect(hunk.rows.contains(where: {
        if case .row(let r) = $0 { return r.relation == .modify }
        return false
    }))
}
