//
//  ModifyAligner.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/15/26.
//

import Foundation

public enum ModifyAligner {

    /// Zip pairing: adjacent delete-run + insert-run => modify pairs
    public static func align(_ changes: [Change<String>]) -> [AlignedChange] {
        var out: [AlignedChange] = []
        out.reserveCapacity(changes.reduce(0) { $0 + $1.values.count })

        var oldIndex = 0
        var newIndex = 0

        var pendingDeletes: [String] = []
        var pendingInserts: [String] = []

        func flushPending() {
            guard !pendingDeletes.isEmpty || !pendingInserts.isEmpty else { return }

            let pairs = min(pendingDeletes.count, pendingInserts.count)

            // pairs -> modify
            if pairs > 0 {
                for k in 0..<pairs {
                    out.append(.modify(
                        old: pendingDeletes[k],
                        new: pendingInserts[k],
                        oldIndex: oldIndex,
                        newIndex: newIndex
                    ))
                    oldIndex += 1
                    newIndex += 1
                }
            }

            // leftovers
            if pendingDeletes.count > pairs {
                for s in pendingDeletes[pairs...] {
                    out.append(.delete(text: s, oldIndex: oldIndex))
                    oldIndex += 1
                }
            }
            if pendingInserts.count > pairs {
                for s in pendingInserts[pairs...] {
                    out.append(.insert(text: s, newIndex: newIndex))
                    newIndex += 1
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
                    out.append(.equal(text: s, oldIndex: oldIndex, newIndex: newIndex))
                    oldIndex += 1
                    newIndex += 1
                }
            case .delete:
                pendingDeletes.append(contentsOf: c.values)
            case .insert:
                pendingInserts.append(contentsOf: c.values)
            }
        }

        flushPending()
        return out
    }
}
