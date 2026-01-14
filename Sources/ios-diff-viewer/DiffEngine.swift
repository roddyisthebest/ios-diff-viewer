//
//  DiffEngine.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public enum DiffEngine {

    public struct Config: Sendable, Equatable {
        public var line: LineDiffEngine.Config
        public var rows: RowsBuilder.Config

        public init(line: LineDiffEngine.Config = .default, rows: RowsBuilder.Config = .default) {
            self.line = line
            self.rows = rows
        }

        public static let `default` = Config()
    }

    public static func diff(old: String, new: String, config: Config = .default) -> DiffResult {
        let changes = LineDiffEngine.diffLines(old: old, new: new, config: config.line)
        let rows = RowsBuilder.build(from: changes, config: config.rows)
        return DiffResult(rows: rows)
    }
}


public extension DiffEngine {
    static func diff(old: String, new: String, inlineTokenization: InlineTokenization) -> DiffResult {
        var cfg = Config.default
        cfg.rows.inline.tokenization = inlineTokenization
        return diff(old: old, new: new, config: cfg)
    }
}
