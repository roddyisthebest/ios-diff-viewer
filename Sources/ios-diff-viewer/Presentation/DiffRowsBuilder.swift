//
//  DiffRowsBuilder.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/15/26.
//

import Foundation

public enum DiffRowsBuilder {

    public struct Config: Sendable, Equatable {
        public var inline: InlineDiffEngine.Config
        public init(inline: InlineDiffEngine.Config = .default) { self.inline = inline }
        public static let `default` = Config()
    }

    public static func build(from aligned: [AlignedChange], config: Config = .default) -> [DiffRow] {
        var rows: [DiffRow] = []
        rows.reserveCapacity(aligned.count)

        for a in aligned {
            switch a {
            case .equal(let text, let oi, let ni):
                rows.append(DiffRow(
                    left: SideLine(number: oi + 1, text: text),
                    right: SideLine(number: ni + 1, text: text),
                    relation: .equal
                ))

            case .delete(let text, let oi):
                rows.append(DiffRow(
                    left: SideLine(number: oi + 1, text: text),
                    right: nil,
                    relation: .delete
                ))

            case .insert(let text, let ni):
                rows.append(DiffRow(
                    left: nil,
                    right: SideLine(number: ni + 1, text: text),
                    relation: .insert
                ))

            case .modify(let old, let new, let oi, let ni):
                let inline = InlineDiffEngine.diff(old: old, new: new, config: config.inline)
                rows.append(DiffRow(
                    left: SideLine(number: oi + 1, text: old),
                    right: SideLine(number: ni + 1, text: new),
                    relation: .modify,
                    inline: inline
                ))
            }
        }

        return rows
    }
}
