//
//  AlignedChange.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/15/26.
//

import Foundation

public enum AlignedChange: Sendable, Equatable {
    case equal(text: String, oldIndex: Int, newIndex: Int)
    case delete(text: String, oldIndex: Int)
    case insert(text: String, newIndex: Int)
    case modify(old: String, new: String, oldIndex: Int, newIndex: Int)
}
