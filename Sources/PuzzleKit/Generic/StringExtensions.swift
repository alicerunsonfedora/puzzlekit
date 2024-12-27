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

    func character(at offset: Int) -> Character {
        let idx = self.index(self.startIndex, offsetBy: offset)
        return self[idx]
    }
}
