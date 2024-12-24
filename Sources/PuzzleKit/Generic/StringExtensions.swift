//
//  StringExtensions.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 21-12-2024.
//

extension String {
    /// Calculates the distance from the start index to the specified index.
    func distance(to index: Self.Index) -> Int {
        self.distance(from: self.startIndex, to: index)
    }
}
