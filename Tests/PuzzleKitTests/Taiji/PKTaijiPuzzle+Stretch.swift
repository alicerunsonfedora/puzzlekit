//
//  PKTaijiPuzzle+Stretch.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 03-01-2025.
//

import Testing
@testable import PuzzleKit

@Suite("Taiji puzzle stretching")
struct TaijiPuzzleStretchTests {
    static let puzzle = PKTaijiPuzzle(size: .init(width: 4, height: 3))
    
    @Test("Puzzle adds empty column")
    func puzzleAddsColumn() async throws {
        let newPuzzle = Self.puzzle.appendingColumn()
        #expect(newPuzzle.width == 5)
        #expect(newPuzzle.height == 3)
    }

    @Test("Puzzle adds empty row")
    func puzzleAddsRow() async throws {
        let newPuzzle = Self.puzzle.appendingRow()
        
        #expect(newPuzzle.width == 4)
        #expect(newPuzzle.height == 4)
    }
    
    @Test("Puzzle removes last column")
    func puzzleRemovesColumn() async throws {
        let newPuzzle = try PKTaijiPuzzle(decoding: "4:+CSw+DSw+DSw0").removingLastColumn()
        #expect(newPuzzle.width == 3)
        #expect(newPuzzle.height == 3)

        #expect(
            newPuzzle.tiles.count { tile in
                tile.symbol == .diamond
            } == 0
        )
    }

    @Test("Puzzle removes last row")
    func puzzleRemovesRows() async throws {
        let newPuzzle = try PKTaijiPuzzle(decoding: "4:+HSw0Sw0Sw0Sw0").removingLastRow()
        #expect(newPuzzle.width == 4)
        #expect(newPuzzle.height == 2)
        
        #expect(
            newPuzzle.tiles.count { tile in
                tile.symbol == .diamond
            } == 0
        )
    }
}
