//
//  RowsBuilderTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//


import Testing
@testable import ios_diff_viewer

private extension Array where Element == DiffRow {
    var signature: String {
        self.map { r in
            switch r.relation {
            case .equal:  return "E(\(r.left?.text ?? ""))"
            case .delete: return "D(\(r.left?.text ?? ""))"
            case .insert: return "I(\(r.right?.text ?? ""))"
            case .modify: return "M(\(r.left?.text ?? "")->\(r.right?.text ?? ""))"
            }
        }.joined(separator: "|")
    }
}

@Test
func rowsBuilder_pairs_delete_insert_as_modify_zip() {
    // delete 2 lines + insert 2 lines => 2 modify rows
    let changes: [Change<String>] = [
        .init(kind: .equal, values: ["a"]),
        .init(kind: .delete, values: ["bbba", "csa"]),
        .init(kind: .insert, values: ["b", "c"]),
        .init(kind: .equal, values: ["d"])
    ]

    let rows = RowsBuilder.build(from: changes)
    #expect(rows.signature == "E(a)|M(bbba->b)|M(csa->c)|E(d)")
}


@Test
func myers_middle_insertion_keeps_tail_equals() {
    let changes = LineDiffEngine.diffLines(old: "a\nb\nc", new: "a\nx\nb\nc")
    let rows = RowsBuilder.build(from: changes)

    let sig = rows.map {
        switch $0.relation {
        case .equal: "E(\($0.left?.text ?? ""))"
        case .delete: "D(\($0.left?.text ?? ""))"
        case .insert: "I(\($0.right?.text ?? ""))"
        case .modify: "M(\($0.left?.text ?? "")->\($0.right?.text ?? ""))"
        }
    }.joined(separator: "|")

    #expect(sig.contains("I(x)"))
    #expect(sig.contains("E(b)"))
    #expect(sig.contains("E(c)"))
}

@Test
func rows_modify_has_inline() {
    let changes: [Change<String>] = [
        .init(kind: .delete, values: ["bbba"]),
        .init(kind: .insert, values: ["b"])
    ]
    let rows = RowsBuilder.build(from: changes)
    #expect(rows.count == 1)
    #expect(rows[0].relation == .modify)
    #expect(rows[0].inline != nil)
}


@Test
func diffEngine_passes_inline_tokenization_to_rowsBuilder() {
    let old = "let count = 10"
    let new = "let count = 12"

    let res = DiffEngine.diff(old: old, new: new, inlineTokenization: .words)

    // find modify row
    let m = res.rows.first(where: { $0.relation == .modify })
    #expect(m != nil)
    #expect(m?.inline != nil)
    #expect(m?.inline?.isTruncated == false)
    // tokenization is internal, but we can at least check the text reconstructs
    #expect(m?.inline?.old.map(\.text).joined() == old)
    #expect(m?.inline?.new.map(\.text).joined() == new)
}
