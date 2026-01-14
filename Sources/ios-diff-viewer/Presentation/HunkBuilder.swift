//
//  HunkBuilder.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public enum HunkBuilder {

    public struct Config: Sendable, Equatable {
        /// Number of unchanged context lines to keep around change blocks.
        public var context: Int

        /// If an unchanged(equal) run length is <= this, keep it as-is (don’t fold).
        public var smallEqualRunThreshold: Int

        public init(context: Int = 3, smallEqualRunThreshold: Int = 2) {
            self.context = context
            self.smallEqualRunThreshold = smallEqualRunThreshold
        }

        public static let `default` = Config()
    }

    /// Build a single hunk-like display stream from full diff rows.
    /// (Later you can split into multiple hunks if you want.)
    public static func build(from rows: [DiffRow], config: Config = .default) -> DiffHunk {
        // If no changes, show everything (or you can fold all, up to you)
        let hasChange = rows.contains { $0.relation != .equal }
        if !hasChange {
            return DiffHunk(rows: rows.map(DiffDisplayRow.row))
        }

        // Mark which indices should be visible (changes + surrounding context)
        let n = rows.count
        var visible = Array(repeating: false, count: n)

        for i in 0..<n where rows[i].relation != .equal {
            let start = max(0, i - config.context)
            let end = min(n - 1, i + config.context)
            for k in start...end { visible[k] = true }
        }

        // Build display rows: visible rows as-is, invisible equal runs collapsed
        var out: [DiffDisplayRow] = []
        out.reserveCapacity(n)

        var i = 0
        while i < n {
            if visible[i] {
                out.append(.row(rows[i]))
                i += 1
                continue
            }

            // invisible segment: should be all equals (by construction)
            let start = i
            var oldCount = 0
            var newCount = 0

            while i < n, !visible[i] {
                if rows[i].relation == .equal {
                    oldCount += 1
                    newCount += 1
                } else {
                    // Safety: if something non-equal slipped in, show it.
                    break
                }
                i += 1
            }

            let runLen = i - start
            if runLen <= config.smallEqualRunThreshold {
                // too small: just show them
                for k in start..<i { out.append(.row(rows[k])) }
            } else {
                out.append(.omitted(oldCount: oldCount, newCount: newCount))
            }
        }

        // Coalesce adjacent omitted blocks (just in case)
        out = coalesceOmitted(out)
        return DiffHunk(rows: out)
    }

    private static func coalesceOmitted(_ rows: [DiffDisplayRow]) -> [DiffDisplayRow] {
        var out: [DiffDisplayRow] = []
        out.reserveCapacity(rows.count)

        for r in rows {
            if case .omitted(let o1, let n1) = r,
               let last = out.last,
               case .omitted(let o0, let n0) = last {
                out[out.count - 1] = .omitted(oldCount: o0 + o1, newCount: n0 + n1)
            } else {
                out.append(r)
            }
        }
        return out
    }
}
