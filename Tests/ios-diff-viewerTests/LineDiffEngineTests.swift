//
//  LineDiffEngineTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//


import Testing
@testable import ios_diff_viewer

private extension Array where Element == Change<String> {
    var signature: String {
        self.map { c in
            let prefix: String = switch c.kind {
            case .equal: "E"
            case .delete: "D"
            case .insert: "I"
            }
            return "\(prefix)(\(c.values.joined(separator: "\\n")))"
        }.joined(separator: "|")
    }
}

@Test
func lineDiff_middle_insertion_keeps_equals() {
    let changes = LineDiffEngine.diffLines(old: "a\nb\nc", new: "a\nx\nb\nc")
    // do not over constrain exact grouping too much, but should include x as insert and keep a,b,c equals
    #expect(changes.contains(where: { $0.kind == .insert && $0.values == ["x"] }))
    #expect(changes.contains(where: { $0.kind == .equal && $0.values.contains("a") }))
    #expect(changes.contains(where: { $0.kind == .equal && $0.values.contains("b") }))
    #expect(changes.contains(where: { $0.kind == .equal && $0.values.contains("c") }))
}
