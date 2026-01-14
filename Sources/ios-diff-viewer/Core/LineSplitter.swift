//
//  LineSplitter.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public enum LineSplitter {
    /// Splits by newline while keeping empty lines (important for diff viewers).
    /// Also removes a "phantom" last empty line when the original text ends with '\n'.
    public static func splitKeepingEmpty(_ text: String) -> [String] {
        if text.isEmpty { return [] }

        var lines = text
            .split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
            .map(String.init)

        if text.last?.isNewline == true, lines.last == "" {
            lines.removeLast()
        }
        return lines
    }
}
