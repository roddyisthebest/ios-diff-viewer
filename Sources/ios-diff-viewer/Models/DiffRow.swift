//
//  DiffRow.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public enum DiffRowRelation: Sendable, Equatable {
    case equal
    case delete
    case insert
    case modify
}

public struct DiffRow: Sendable, Equatable {
    public let left: SideLine?
    public let right: SideLine?
    public let relation: DiffRowRelation
    
    public let inline: InlineDiff?


    public init(left: SideLine?, right: SideLine?, relation: DiffRowRelation, inline: InlineDiff? = nil) {
        self.left = left
        self.right = right
        self.relation = relation
        self.inline = inline
    }
}
