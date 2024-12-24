//
//  PKFloodFillable.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

import Testing
@testable import PuzzleKit

extension PKTaijiTile {
    static func emptyFilled() -> Self {
        var tile = self.empty()
        tile.filled = true
        return tile
    }
}

@Suite("Flood Fill")
struct PKFloodFillTests {
    @Test("Flood Fill Region Matches (2x2)")
    func floodFillRegionMatches() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "2:2220")
        #expect(puzzle.tiles.count == 4)
        #expect(puzzle.tiles == [
            .emptyFilled(),
            .emptyFilled(),
            .emptyFilled(),
            .empty()
        ])

        let region = puzzle.getFloodFilledRegion(startingAt: .one)
        #expect(region.count == 3)

        let otherRegion = puzzle.getFloodFilledRegion(startingAt: .init(x: 2, y: 2))
        #expect(otherRegion.count == 1)
    }

    @Test("Flood Fill Region Matches (Complex)",
          arguments: zip([
            PKGridCoordinate.one,
            PKGridCoordinate(x: 4, y: 1),
            PKGridCoordinate(x: 6, y: 2),
            PKGridCoordinate(x: 2, y: 4),
            PKGridCoordinate(x: 5, y: 4)
          ], [3, 8, 9, 2, 2]))
    func floodFillRegionMatchesComplex(coordinate: PKGridCoordinate, size: Int) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "6:0Cw+B2Y2Aw2Cw2222Dw2Sw+CDw0Bw+CCw0Tw22Sw02Uw2")
        #expect(puzzle.tiles.count == 24)

        let region = puzzle.getFloodFilledRegion(startingAt: coordinate)
        #expect(region.count == size)
    }
}
