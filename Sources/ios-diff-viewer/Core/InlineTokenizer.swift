//
//  InlineTokenizer.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public enum InlineTokenization: Sendable, Equatable {
    /// Grapheme clusters (Character). Most precise but can be heavy.
    case characters
    /// Word-ish tokens: word / whitespace / punctuation
    case words
    /// Code-friendly: identifier/number/whitespace/symbol
    case codeLike
}

enum InlineTokenizer {
    static func tokenize(_ s: String, mode: InlineTokenization) -> [String] {
        switch mode {
        case .characters:
            return s.map { String($0) }

        case .words:
            return tokenizeWords(s)

        case .codeLike:
            return tokenizeCodeLike(s)
        }
    }

    // MARK: - words

    private static func tokenizeWords(_ s: String) -> [String] {
        // Groups into: whitespace, word(letters/digits/_), punctuation/others
        var out: [String] = []
        out.reserveCapacity(max(1, s.count / 2))

        var buf = ""
        buf.reserveCapacity(8)

        enum Kind { case space, word, punct }
        var current: Kind? = nil

        func kind(of ch: Character) -> Kind {
            if ch.isWhitespace { return .space }
            if ch.isLetter || ch.isNumber || ch == "_" { return .word }
            return .punct
        }

        func flush() {
            guard !buf.isEmpty else { return }
            out.append(buf)
            buf.removeAll(keepingCapacity: true)
        }

        for ch in s {
            let k = kind(of: ch)
            if current == nil {
                current = k
                buf.append(ch)
                continue
            }
            if k == current {
                buf.append(ch)
            } else {
                flush()
                current = k
                buf.append(ch)
            }
        }
        flush()
        return out
    }

    // MARK: - codeLike

    private static func tokenizeCodeLike(_ s: String) -> [String] {
        // Groups into: whitespace, identifier([A-Za-z0-9_]+ starting with letter/_), number([0-9]+ and dots), symbol(each run of non-alnum non-space)
        var out: [String] = []
        out.reserveCapacity(max(1, s.count / 2))

        var buf = ""
        buf.reserveCapacity(8)

        enum Kind { case space, ident, number, symbol }
        var current: Kind? = nil

        func kind(of ch: Character) -> Kind {
            if ch.isWhitespace { return .space }
            if ch.isLetter || ch == "_" { return .ident }
            if ch.isNumber { return .number }
            // dot: attach to number if currently number, else symbol
            if ch == "." { return current == .number ? .number : .symbol }
            return .symbol
        }

        func flush() {
            guard !buf.isEmpty else { return }
            out.append(buf)
            buf.removeAll(keepingCapacity: true)
        }

        for ch in s {
            let k = kind(of: ch)
            if current == nil {
                current = k
                buf.append(ch)
                continue
            }

            // ident can absorb digits after it started
            if current == .ident, (ch.isLetter || ch.isNumber || ch == "_") {
                buf.append(ch); continue
            }

            // number can absorb digits (and dots handled in kind())
            if current == .number, (ch.isNumber || ch == ".") {
                buf.append(ch); continue
            }

            if k == current {
                buf.append(ch)
            } else {
                flush()
                current = k
                buf.append(ch)
            }
        }

        flush()
        return out
    }
}
