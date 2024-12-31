//
//  PKTaijiPuzzleInteractions.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

import Testing
@testable import PuzzleKit

typealias Coord = PKGridCoordinate

@Suite("Taiji Puzzle Interactions")
struct PKTaijiPuzzleInteractions {
    @Test("To Index Returns Valid Index",
          arguments: zip(
            [Coord.one, Coord(x: 2, y: 1), Coord(x: 1, y: 2), Coord(x: 2, y: 2)],
            [0, 1, 2, 3]))
    func toIndexReturnsValidIndex(coordinate: PKGridCoordinate, expectedIndex: Int) async throws {
        let boardWidth = 2
        let tiles = 4
        #expect(coordinate.toIndex(wrappingAround: boardWidth, in: tiles) == expectedIndex)
    }

    @Test("To Index Returns Out of Range")
    func toIndexReturnsOutOfRange() async throws {
        let boardWidth = 5
        let coordinate = PKGridCoordinate(x: 5, y: 5)
        #expect(coordinate.toIndex(wrappingAround: boardWidth, in: 10) == -1)
    }

    @Test("To Index Returns Valid Index",
          arguments: zip(
            [0, 1, 2, 3],
            [Coord.one, Coord(x: 2, y: 1), Coord(x: 1, y: 2), Coord(x: 2, y: 2)]))
    func toCoordinateReturnsValid(index: Int, coordinate: PKGridCoordinate) async throws {
        let coord = index.toCoordinate(wrappingAround: 2)
        #expect(coord == coordinate)
    }
    

    @Test("Tile Flips In Bounds")
    func tileFlipsWhenInBounds() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "5:+J")
        let flipped = puzzle.flippingTile(at: .init(x: 2, y: 1))

        #expect(flipped.tiles.count == 10)
        #expect(flipped.tiles[1].filled == true)
    }

    @Test("Tile Remains when Out of Bounds")
    func tileRemainsOutOfBounds() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "5:+J")
        let flipped = puzzle.flippingTile(at: .init(x: 5, y: 5))

        #expect(flipped.tiles.count == 10)
        #expect(puzzle.tiles.allSatisfy({ tile in tile.filled == false }))
    }

    @Test("Tile symbol is replaced")
    func tileSymbolReplaces() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "3:+I")
        let replaced = puzzle.replacingSymbol(at: .init(x: 2, y: 2), with: .diamond)
        
        #expect(replaced.tiles.count == 9)
        #expect(replaced.tile(at: .init(x: 2, y: 2))?.symbol == .diamond)
    }

    @Test("Tile state is updated")
    func tileStateReplaces() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "3:+I")
        let updated = puzzle.applyingState(at: .init(x: 1, y: 2), with: .fixed)
    
        #expect(updated.tiles.count == 9)
        #expect(updated.tile(at: .init(x: 1, y: 2))?.state == .fixed)
    }
}
