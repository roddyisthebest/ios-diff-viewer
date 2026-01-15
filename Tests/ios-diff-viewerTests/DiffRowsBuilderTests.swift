//
//  DiffRowsBuilderTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/15/26.
//

import Testing
@testable import ios_diff_viewer

private extension Array where Element == DiffRow {
    var signature: String {
        self.map { row in
            switch row.relation {
            case .equal:
                return "E(\(row.left?.text ?? ""))"
            case .delete:
                return "D(\(row.left?.text ?? ""))"
            case .insert:
                return "I(\(row.right?.text ?? ""))"
            case .modify:
                return "M(\(row.left?.text ?? "")->\(row.right?.text ?? ""))"
            }
        }.joined(separator: "|")
    }
}

@Test
func rowBuilder_maps_aligned_changes_to_rows_and_numbers() {
    let aligned: [AlignedChange] = [
        .equal(text: "a", oldIndex: 0, newIndex: 0),
        .modify(old: "bbba", new: "b", oldIndex: 1, newIndex: 1),
        .delete(text: "csa", oldIndex: 2),
        .insert(text: "x", newIndex: 2),
        .equal(text: "d", oldIndex: 3, newIndex: 3),
    ]

    let rows = DiffRowsBuilder.build(from: aligned)

    #expect(rows.signature == "E(a)|M(bbba->b)|D(csa)|I(x)|E(d)")

    // line numbers should be 1-based
    #expect(rows[0].left?.number == 1)
    #expect(rows[0].right?.number == 1)

    #expect(rows[1].left?.number == 2)
    #expect(rows[1].right?.number == 2)

    #expect(rows[2].left?.number == 3)
    #expect(rows[2].right == nil)

    #expect(rows[3].left == nil)
    #expect(rows[3].right?.number == 3)
}

@Test
func rowBuilder_attaches_inline_only_for_modify() {
    let aligned: [AlignedChange] = [
        .equal(text: "a", oldIndex: 0, newIndex: 0),
        .modify(old: "bbba", new: "b", oldIndex: 1, newIndex: 1),
        .insert(text: "x", newIndex: 2),
    ]

    let rows = DiffRowsBuilder.build(from: aligned)

    #expect(rows[0].inline == nil)
    #expect(rows[1].relation == .modify)
    #expect(rows[1].inline != nil)
    #expect(rows[2].inline == nil)

    // inline should reconstruct original texts
    let inline = rows[1].inline!
    #expect(inline.old.map(\.text).joined() == "bbba")
    #expect(inline.new.map(\.text).joined() == "b")
}

@Test
func rowBuilder_respects_inline_config_tokenization() {
    // Just ensure we can pass config without crashing and reconstruct text.
    var inlineCfg = InlineDiffEngine.Config.default
    inlineCfg.tokenization = .codeLike
    let cfg = DiffRowsBuilder.Config(inline: inlineCfg)

    let aligned: [AlignedChange] = [
        .modify(old: "foo(bar: 1)", new: "foo(bar: 2)", oldIndex: 0, newIndex: 0)
    ]

    let rows = DiffRowsBuilder.build(from: aligned, config: cfg)
    #expect(rows.count == 1)
    #expect(rows[0].inline != nil)
    #expect(rows[0].inline?.old.map(\.text).joined() == "foo(bar: 1)")
    #expect(rows[0].inline?.new.map(\.text).joined() == "foo(bar: 2)")
}
