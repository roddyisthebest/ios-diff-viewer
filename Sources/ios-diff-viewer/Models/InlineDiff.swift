//
//  InlineDiff.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/14/26.
//

import Foundation

public enum InlinePieceKind: Sendable, Equatable {
    case equal
    case delete   // shown on OLD
    case insert   // shown on NEW
}

public struct InlinePiece: Sendable, Equatable {
    public let kind: InlinePieceKind
    public let text: String

    public init(kind: InlinePieceKind, text: String) {
        self.kind = kind
        self.text = text
    }
}

public struct InlineDiff: Sendable, Equatable {
    public let old: [InlinePiece]
    public let new: [InlinePiece]

    /// True when inline highlight was disabled due to limits.
    public let isTruncated: Bool

    public init(old: [InlinePiece], new: [InlinePiece], isTruncated: Bool = false) {
        self.old = old
        self.new = new
        self.isTruncated = isTruncated
    }
}
