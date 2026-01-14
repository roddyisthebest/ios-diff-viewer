//
//  HunkExpanderTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Testing
@testable import ios_diff_viewer

@Test
func expander_expandOne_replaces_omitted_with_rows() {
    let oldLines = (0..<30).map { "line-\($0)" }
    var newLines = oldLines
    newLines[15] = "line-15-modified"

    let old = oldLines.joined(separator: "\n")
    let new = newLines.joined(separator: "\n")

    let res = DiffEngine.diff(old: old, new: new)
    let hunk = HunkBuilder.build(from: res.rows, config: .init(context: 2, smallEqualRunThreshold: 1))

    let idx = hunk.rows.firstIndex(where: { if case .omitted = $0 { return true } else { return false } })
    #expect(idx != nil)

    let expanded = HunkExpander.expandOne(hunk, at: idx!)
    // That omitted should be gone at that index now
    #expect({
        if case .omitted = expanded.rows[idx!] { return false }
        return true
    }())
}

@Test
func expander_expandAll_removes_all_omitted() {
    let oldLines = (0..<50).map { "line-\($0)" }
    var newLines = oldLines
    newLines[20] = "line-20-modified"

    let res = DiffEngine.diff(old: oldLines.joined(separator: "\n"),
                              new: newLines.joined(separator: "\n"))
    let hunk = HunkBuilder.build(from: res.rows, config: .init(context: 1, smallEqualRunThreshold: 0))

    let all = HunkExpander.expandAll(hunk)

    #expect(all.rows.contains(where: { if case .omitted = $0 { return true } else { return false } }) == false)
    // After expandAll, count should match source rows exactly
    #expect(all.rows.count == all.sourceRows.count)
}
