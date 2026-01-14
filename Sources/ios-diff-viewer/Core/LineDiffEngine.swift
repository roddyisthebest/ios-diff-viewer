//
//  LineDiffEngine.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public enum LineDiffEngine {

    public struct Config: Sendable, Equatable {
        /// Safety: if Myers needs more than this edit distance, we fall back
        /// to "delete all + insert all" (prevents worst-case blow-ups).
        public var maxEditDistance: Int

        public init(maxEditDistance: Int = 20_000) {
            self.maxEditDistance = maxEditDistance
        }

        public static let `default` = Config()
    }

    /// Diff two texts line-by-line and return jsdiff-like runs.
    public static func diffLines(old: String, new: String, config: Config = .default) -> [Change<String>] {
        let a = LineSplitter.splitKeepingEmpty(old)
        let b = LineSplitter.splitKeepingEmpty(new)
        return diffSequences(a, b, config: config)
    }

    // MARK: - Myers for sequences

    private enum Edit {
        case eq(String)
        case del(String)
        case ins(String)
    }

    private static func diffSequences(_ a: [String], _ b: [String], config: Config) -> [Change<String>] {
        let n = a.count
        let m = b.count

        if n == 0, m == 0 { return [] }
        if n == 0 { return [Change(kind: .insert, values: b)] }
        if m == 0 { return [Change(kind: .delete, values: a)] }

        // Myers: worst D <= n + m
        let max = n + m
        let offset = max
        let size = 2 * max + 1

        var v = Array(repeating: -1, count: size)
        v[offset + 1] = 0

        var trace: [[Int]] = []
        trace.reserveCapacity(min(max, config.maxEditDistance) + 1)

        for d in 0...max {
            // Safety: abort if too hard (very different / huge)
            if d > config.maxEditDistance {
                var out: [Change<String>] = []
                out.append(Change(kind: .delete, values: a))
                out.append(Change(kind: .insert, values: b))
                return out
            }

            var vNext = v

            for k in stride(from: -d, through: d, by: 2) {
                let idx = k + offset

                let xStart: Int
                if k == -d || (k != d && v[idx - 1] < v[idx + 1]) {
                    // Down: insertion in a (advance y)
                    xStart = v[idx + 1]
                } else {
                    // Right: deletion from a (advance x)
                    xStart = v[idx - 1] + 1
                }

                var x = xStart
                var y = x - k

                // Snake: consume equals
                while x < n, y < m, x >= 0, y >= 0, a[x] == b[y] {
                    x += 1
                    y += 1
                }

                vNext[idx] = x

                if x >= n && y >= m {
                    trace.append(vNext)
                    let edits = backtrack(trace: trace, a: a, b: b, offset: offset)
                    return coalesce(edits)
                }
            }

            trace.append(vNext)
            v = vNext
        }

        // Fallback (should not happen)
        let edits = backtrack(trace: trace, a: a, b: b, offset: offset)
        return coalesce(edits)
    }

    private static func backtrack(trace: [[Int]], a: [String], b: [String], offset: Int) -> [Edit] {
        let n = a.count
        let m = b.count

        var x = n
        var y = m

        var reversed: [Edit] = []
        reversed.reserveCapacity(n + m)

        guard trace.count >= 2 else {
            // minimal fallback
            if n > 0 { reversed.append(contentsOf: a.reversed().map(Edit.del)) }
            if m > 0 { reversed.append(contentsOf: b.reversed().map(Edit.ins)) }
            return reversed.reversed()
        }

        for d in stride(from: trace.count - 1, through: 1, by: -1) {
            let vPrev = trace[d - 1]
            let k = x - y
            let idx = k + offset

            let prevK: Int
            if k == -d || (k != d && vPrev[idx - 1] < vPrev[idx + 1]) {
                prevK = k + 1
            } else {
                prevK = k - 1
            }

            let prevX = vPrev[prevK + offset]
            let prevY = prevX - prevK

            // equal snake backwards
            while x > prevX, y > prevY {
                if x <= 0 || y <= 0 { break }
                reversed.append(.eq(a[x - 1]))
                x -= 1
                y -= 1
            }

            // one step (ins or del)
            if x == prevX {
                // insertion (must move y)
                if y > 0 {
                    reversed.append(.ins(b[y - 1]))
                    y -= 1
                }
            } else {
                // deletion (must move x)
                if x > 0 {
                    reversed.append(.del(a[x - 1]))
                    x -= 1
                }
            }
        }

        // leftovers (safe)
        while x > 0, y > 0, a[x - 1] == b[y - 1] {
            reversed.append(.eq(a[x - 1]))
            x -= 1
            y -= 1
        }
        while x > 0 {
            reversed.append(.del(a[x - 1]))
            x -= 1
        }
        while y > 0 {
            reversed.append(.ins(b[y - 1]))
            y -= 1
        }

        return reversed.reversed()
    }

    // MARK: - Coalesce edits -> Change runs

    private static func coalesce(_ edits: [Edit]) -> [Change<String>] {
        var out: [Change<String>] = []
        out.reserveCapacity(edits.count / 2 + 1)

        func flush(kind: Change<String>.Kind, buffer: inout [String]) {
            guard !buffer.isEmpty else { return }
            out.append(Change(kind: kind, values: buffer))
            buffer.removeAll(keepingCapacity: true)
        }

        var eq: [String] = []
        var del: [String] = []
        var ins: [String] = []

        for e in edits {
            switch e {
            case .eq(let s):
                flush(kind: .delete, buffer: &del)
                flush(kind: .insert, buffer: &ins)
                eq.append(s)
            case .del(let s):
                flush(kind: .equal, buffer: &eq)
                flush(kind: .insert, buffer: &ins)
                del.append(s)
            case .ins(let s):
                flush(kind: .equal, buffer: &eq)
                flush(kind: .delete, buffer: &del)
                ins.append(s)
            }
        }

        flush(kind: .equal, buffer: &eq)
        flush(kind: .delete, buffer: &del)
        flush(kind: .insert, buffer: &ins)

        return out
    }
}
