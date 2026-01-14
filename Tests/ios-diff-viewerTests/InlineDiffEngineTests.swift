//
//  InlineDiffEngineTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Testing
@testable import ios_diff_viewer

@Test
func inline_bbba_to_b_has_deletes_on_old() {
    let diff = InlineDiffEngine.diff(old: "bbba", new: "b")
    #expect(diff.isTruncated == false)
    #expect(diff.old.contains(where: { $0.kind == .delete }))
    #expect(diff.new.map(\.text).joined() == "b")
}

@Test
func inline_should_disable_when_too_long() {
    let old = String(repeating: "a", count: 10_000) + "X"
    let new = String(repeating: "a", count: 10_000) + "Y"

    let diff = InlineDiffEngine.diff(old: old, new: new) // default limit 4000
    #expect(diff.isTruncated == true)
    #expect(diff.old.map(\.text).joined() == old)
    #expect(diff.new.map(\.text).joined() == new)
    #expect(diff.old.contains(where: { $0.kind == .delete }) == false)
    #expect(diff.new.contains(where: { $0.kind == .insert }) == false)
}
