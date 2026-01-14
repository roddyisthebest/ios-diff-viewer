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

@Test
func inline_words_tokenization_produces_some_highlight_for_replacement() {
    let cfg = InlineDiffEngine.Config(tokenization: .words)
    let diff = InlineDiffEngine.diff(old: "let count = 10", new: "let count = 12", config: cfg)

    #expect(diff.isTruncated == false)
    // should have some change on either side
    #expect(diff.old.contains(where: { $0.kind == .delete }) || diff.new.contains(where: { $0.kind == .insert }))
}

@Test
func inline_codeLike_tokenization_handles_symbols_nicely() {
    let cfg = InlineDiffEngine.Config(tokenization: .codeLike)
    let diff = InlineDiffEngine.diff(old: "foo(bar: 1)", new: "foo(bar: 2)", config: cfg)

    #expect(diff.isTruncated == false)
    #expect(diff.old.map(\.text).joined() == "foo(bar: 1)")
    #expect(diff.new.map(\.text).joined() == "foo(bar: 2)")
}

@Test
func inline_should_disable_when_too_many_tokens() {
    let long = (0..<10_000).map { _ in "a" }.joined(separator: " ") // many word tokens
    let cfg = InlineDiffEngine.Config(maxTokensPerLine: 2000, tokenization: .words)
    let diff = InlineDiffEngine.diff(old: long, new: long + " x", config: cfg)

    #expect(diff.isTruncated == true)
}
