//
//  RowsBuilder.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//


import Foundation

public enum RowsBuilder {

    public static func build(from changes: [Change<String>]) -> [DiffRow] {
        var rows: [DiffRow] = []
        rows.reserveCapacity(changes.reduce(0) { $0 + $1.values.count })

        var oldLineNo = 1
        var newLineNo = 1

        var pendingDeletes: [String] = []
        var pendingInserts: [String] = []

        func flushPending() {
            guard !pendingDeletes.isEmpty || !pendingInserts.isEmpty else { return }

            let pairs = min(pendingDeletes.count, pendingInserts.count)

            // modify pairs (zip)
            if pairs > 0 {
                for k in 0..<pairs {
                    let left = SideLine(number: oldLineNo, text: pendingDeletes[k])
                    let right = SideLine(number: newLineNo, text: pendingInserts[k])
                    rows.append(DiffRow(left: left, right: right, relation: .modify))
                    oldLineNo += 1
                    newLineNo += 1
                }
            }

            // leftover deletes
            if pendingDeletes.count > pairs {
                for s in pendingDeletes[pairs...] {
                    let left = SideLine(number: oldLineNo, text: s)
                    rows.append(DiffRow(left: left, right: nil, relation: .delete))
                    oldLineNo += 1
                }
            }

            // leftover inserts
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
