//
//  ModifyAlignerTests.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/15/26.
//

import Testing
@testable import ios_diff_viewer

private extension Array where Element == AlignedChange {
    var signature: String {
        self.map {
            switch $0 {
            case .equal(let t, _, _): return "E(\(t))"
            case .delete(let t, _): return "D(\(t))"
            case .insert(let t, _): return "I(\(t))"
            case .modify(let o, let n, _, _): return "M(\(o)->\(n))"
            }
        }.joined(separator: "|")
    }
}

@Test
func aligner_pairs_adjacent_delete_insert_into_modify_zip() {
    // old: a bbba csa d
    // new: a b    c   d
    let changes: [Change<String>] = [
        .init(kind: .equal, values: ["a"]),
        .init(kind: .delete, values: ["bbba", "csa"]),
        .init(kind: .insert, values: ["b", "c"]),
        .init(kind: .equal, values: ["d"]),
    ]

    let aligned = ModifyAligner.align(changes)

    // Note: indexes exist, but we assert only ordering + pairing here
    #expect(aligned.signature == "E(a)|M(bbba->b)|M(csa->c)|E(d)")
}

@Test
func aligner_leftover_deletes_remain_deletes() {
    let changes: [Change<String>] = [
        .init(kind: .equal, values: ["a"]),
        .init(kind: .delete, values: ["x", "y", "z"]),
        .init(kind: .insert, values: ["X"]),
        .init(kind: .equal, values: ["b"]),
    ]

    let aligned = ModifyAligner.align(changes)

    // 1 pair => modify(x->X), leftover deletes y,z remain deletes
    #expect(aligned.signature == "E(a)|M(x->X)|D(y)|D(z)|E(b)")
}

@Test
func aligner_leftover_inserts_remain_inserts() {
    let changes: [Change<String>] = [
        .init(kind: .equal, values: ["a"]),
        .init(kind: .delete, values: ["x"]),
        .init(kind: .insert, values: ["X", "Y", "Z"]),
        .init(kind: .equal, values: ["b"]),
    ]

    let aligned = ModifyAligner.align(changes)

    // 1 pair => modify(x->X), leftover inserts Y,Z remain inserts
    #expect(aligned.signature == "E(a)|M(x->X)|I(Y)|I(Z)|E(b)")
}

@Test
func aligner_handles_only_inserts_or_deletes() {
    let onlyInserts: [Change<String>] = [
        .init(kind: .insert, values: ["a", "b"])
    ]
    #expect(ModifyAligner.align(onlyInserts).signature == "I(a)|I(b)")

    let onlyDeletes: [Change<String>] = [
        .init(kind: .delete, values: ["a", "b"])
    ]
    #expect(ModifyAligner.align(onlyDeletes).signature == "D(a)|D(b)")
}

@Test
func aligner_equal_flushes_pending_runs() {
    // delete/insert pending should flush before equal
    let changes: [Change<String>] = [
        .init(kind: .delete, values: ["x"]),
        .init(kind: .insert, values: ["X"]),
        .init(kind: .equal, values: ["ANCHOR"]),
        .init(kind: .delete, values: ["y"]),
        .init(kind: .insert, values: ["Y"]),
    ]

    let aligned = ModifyAligner.align(changes)
    #expect(aligned.signature == "M(x->X)|E(ANCHOR)|M(y->Y)")
}
