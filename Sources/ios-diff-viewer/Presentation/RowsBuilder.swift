//
//  RowsBuilder.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//


import Foundation

public enum RowsBuilder {

    public struct Config: Sendable, Equatable {
        public var inline: InlineDiffEngine.Config

        public init(inline: InlineDiffEngine.Config = .default) {
            self.inline = inline
        }

        public static let `default` = Config()
    }

    public static func build(from changes: [Change<String>], config: Config = .default) -> [DiffRow] {
        var rows: [DiffRow] = []
        rows.reserveCapacity(changes.reduce(0) { $0 + $1.values.count })

        var oldLineNo = 1
        var newLineNo = 1

        var pendingDeletes: [String] = []
        var pendingInserts: [String] = []

        func flushPending() {
            guard !pendingDeletes.isEmpty || !pendingInserts.isEmpty else { return }

            let pairs = min(pendingDeletes.count, pendingInserts.count)

            if pairs > 0 {
                for k in 0..<pairs {
                    let leftText = pendingDeletes[k]
                    let rightText = pendingInserts[k]

                    let left = SideLine(number: oldLineNo, text: leftText)
                    let right = SideLine(number: newLineNo, text: rightText)

                    let inline = InlineDiffEngine.diff(old: leftText, new: rightText, config: config.inline)

                    rows.append(DiffRow(left: left, right: right, relation: .modify, inline: inline))
                    oldLineNo += 1
                    newLineNo += 1
                }
            }

            if pendingDeletes.count > pairs {
                for s in pendingDeletes[pairs...] {
                    let left = SideLine(number: oldLineNo, text: s)
                    rows.append(DiffRow(left: left, right: nil, relation: .delete))
                    oldLineNo += 1
                }
            }

            if pendingInserts.count > pairs {
                for s in pendingInserts[pairs...] {
                    let right = SideLine(number: newLineNo, text: s)
                    rows.append(DiffRow(left: nil, right: right, relation: .insert))
                    newLineNo += 1
                }
            }

            pendingDeletes.removeAll(keepingCapacity: true)
            pendingInserts.removeAll(keepingCapacity: true)
        }

        for c in changes {
            switch c.kind {
            case .equal:
                flushPending()
                for s in c.values {
                    let left = SideLine(number: oldLineNo, text: s)
                    let right = SideLine(number: newLineNo, text: s)
                    rows.append(DiffRow(left: left, right: right, relation: .equal))
                    oldLineNo += 1
                    newLineNo += 1
                }

            case .delete:
                pendingDeletes.append(contentsOf: c.values)

            case .insert:
                pendingInserts.append(contentsOf: c.values)
            }
        }

        flushPending()
        return rows
    }
}
