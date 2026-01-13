//
//  Change.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

/// jsdiff-like run model.
/// - equal: unchanged items
/// - delete: removed from OLD
/// - insert: added in NEW
public struct Change<Element: Sendable & Equatable>: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case equal
        case delete
        case insert
    }

    public let kind: Kind
    public let values: [Element]

    public init(kind: Kind, values: [Element]) {
        self.kind = kind
        self.values = values
    }
}
