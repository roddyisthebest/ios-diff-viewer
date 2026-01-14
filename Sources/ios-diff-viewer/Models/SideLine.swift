//
//  SideLine.swift
//  ios-diff-viewer
//
//  Created by 배성연 on 1/13/26.
//

import Foundation

public struct SideLine: Sendable, Equatable {
    public let number: Int
    public let text: String

    public init(number: Int, text: String) {
        self.number = number
        self.text = text
    }
}
