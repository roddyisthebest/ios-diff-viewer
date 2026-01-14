//
//  InlineDiffEngine.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//
import Foundation

public enum InlineDiffEngine {

    public struct Config: Sendable, Equatable {
        public var maxCharsPerLine: Int
        public var maxDpCells: Int

        public init(maxCharsPerLine: Int = 4_000, maxDpCells: Int = 8_000_000) {
            self.maxCharsPerLine = maxCharsPerLine
            self.maxDpCells = maxDpCells
        }

        public static let `default` = Config()
    }

    private enum Edit { case eq(Character), del(Character), ins(Character) }

    public static func diff(old: String, new: String, config: Config = .default) -> InlineDiff {
        if old == new {
            let p = InlinePiece(kind: .equal, text: old)
            return InlineDiff(old: old.isEmpty ? [] : [p], new: new.isEmpty ? [] : [p], isTruncated: false)
        }

        let a = Array(old)
        let b = Array(new)

        if a.count > config.maxCharsPerLine || b.count > config.maxCharsPerLine {
            return fallback(old: old, new: new)
        }

        let cells = (a.count + 1) * (b.count + 1)
        if cells > config.maxDpCells {
            return fallback(old: old, new: new)
        }

        if a.isEmpty {
            return InlineDiff(old: [], new: [InlinePiece(kind: .insert, text: new)], isTruncated: false)
        }
        if b.isEmpty {
            return InlineDiff(old: [InlinePiece(kind: .delete, text: old)], new: [], isTruncated: false)
        }

        var dp = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1] + 1
                } else {
                    dp[i][j] = max(dp[i - 1][j], dp[i][j - 1])
                }
            }
        }

        var edits: [Edit] = []
        edits.reserveCapacity(a.count + b.count)

        var i = a.count
        var j = b.count

        while i > 0 || j > 0 {
            if i > 0, j > 0, a[i - 1] == b[j - 1] {
                edits.append(.eq(a[i - 1]))
                i -= 1; j -= 1
            } else if i > 0, (j == 0 || dp[i - 1][j] >= dp[i][j - 1]) {
                edits.append(.del(a[i - 1]))
                i -= 1
            } else {
                edits.append(.ins(b[j - 1]))
                j -= 1
            }
        }

        edits.reverse()
        return buildPieces(from: edits)
    }

    private static func fallback(old: String, new: String) -> InlineDiff {
        let o = old.isEmpty ? [] : [InlinePiece(kind: .equal, text: old)]
        let n = new.isEmpty ? [] : [InlinePiece(kind: .equal, text: new)]
        return InlineDiff(old: o, new: n, isTruncated: true)
    }

    private static func buildPieces(from edits: [Edit]) -> InlineDiff {
        var oldPieces: [InlinePiece] = []
        var newPieces: [InlinePiece] = []
        oldPieces.reserveCapacity(edits.count / 2 + 1)
        newPieces.reserveCapacity(edits.count / 2 + 1)

        func append(_ arr: inout [InlinePiece], kind: InlinePieceKind, ch: Character) {
            if let last = arr.last, last.kind == kind {
                arr[arr.count - 1] = InlinePiece(kind: kind, text: last.text + String(ch))
            } else {
                arr.append(InlinePiece(kind: kind, text: String(ch)))
            }
        }

        for e in edits {
            switch e {
            case .eq(let ch):
                append(&oldPieces, kind: .equal, ch: ch)
                append(&newPieces, kind: .equal, ch: ch)
            case .del(let ch):
                append(&oldPieces, kind: .delete, ch: ch)
            case .ins(let ch):
                append(&newPieces, kind: .insert, ch: ch)
            }
        }

        return InlineDiff(old: oldPieces, new: newPieces, isTruncated: false)
    }
}
