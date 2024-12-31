//
//  PKTaijiPuzzle.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 21-12-2024.
//

import Foundation

/// A representation of a Taiji puzzle.
public struct PKTaijiPuzzle: Equatable, Sendable {
    /// The source string that generated the puzzle.
    ///
    /// This source string should follow the specifications for the Taiji puzzle code defined in
    /// <doc:Taiji#Code-representation>. If the puzzle was created using the ``init(size:)`` initializer, this will be
    /// an empty string.
    @available(*, deprecated, message: "Encode the puzzle using the string initializer.")
    public internal(set) var source: String

    /// The array of tiles the puzzle board contains.
    public internal(set) var tiles: [PKTaijiTile]

    /// The width of the puzzle board.
    public internal(set) var width: Int

    /// The mechanics that are present in the puzzle board.
    public internal(set) var mechanics: PKTaijiMechanics

    /// Creates an empty Taiji puzzle board of a given size.
    ///
    /// The board will consist of a series of empty, normal tiles. To change the symbols for any of the tiles, refer to
    /// <doc:PKTaijiPuzzle#Manipulating-Tiles>.
    ///
    /// - Parameter size: The size of the board.
    public init(size: CGSize) {
        self.source = ""
        self.width = Int(size.width)
        self.tiles = Array(repeating: .empty(), count: Int(size.width * size.height))
        self.mechanics = []
    }

    /// Creates a puzzle by decoding a puzzle code string.
    ///
    /// - Parameter source: The source string to decode from.
    /// - SeeAlso: For more information on the Taiji puzzle code, refer to <doc:Taiji#Code-representation>.
    public init(decoding source: String) throws(PKTaijiPuzzleDecoderError) {
        let (boardWidth, tiles, mechanics) = try PKTaijiDecoder.decode(from: source)
        self.source = source
        self.tiles = tiles
        self.width = boardWidth
        self.mechanics = mechanics
    }
}

public extension PKTaijiPuzzle {
    /// Validates the current puzzle, checking for any unsatisfied constraints.
    /// - Returns: The result from validation.
    func validate() -> PKTaijiPuzzleValidator.ValidationResult {
        PKTaijiPuzzleValidator(puzzle: self).validate()
    }
}

extension PKTaijiPuzzle: PKGrid {
    public typealias Tile = PKTaijiTile

    public var height: Int {
        tiles.count / width
    }

    public func tile(at coordinate: PKGridCoordinate) -> PKTaijiTile? {
        let index = coordinate.toIndex(relativeTo: self)
        guard index > -1, index < tiles.count else { return nil }
        return self.tiles[index]
    }

    public func tile(above coordinate: PKGridCoordinate) -> PKTaijiTile? {
        let index = coordinate.aboveOrNil()?.toIndex(relativeTo: self)
        guard let index, index >= 1, index < tiles.count else { return nil }
        return self.tiles[index]
    }

    public func tile(before coordinate: PKGridCoordinate) -> PKTaijiTile? {
        let index = coordinate.beforeOrNil()?.toIndex(relativeTo: self)
        guard let index, index >= 1, index < tiles.count else { return nil }
        return self.tiles[index]
    }

    public func tile(after coordinate: PKGridCoordinate) -> PKTaijiTile? {
        let index = coordinate.after(stoppingAt: self.width)?.toIndex(relativeTo: self)
        guard let index, index >= 1, index < tiles.count else { return nil }
        return self.tiles[index]
    }

    public func tile(below coordinate: PKGridCoordinate) -> PKTaijiTile? {
        let height = tiles.count / width
        let index = coordinate.below(stoppingAt: height)?.toIndex(relativeTo: self)
        guard let index, index >= 1, index < tiles.count else { return nil }
        return self.tiles[index]
    }
}

extension PKTaijiPuzzle: PKFloodFillable {
    public struct Criteria: Equatable {
        var tileFilled: Bool
    }

    public func getCriteria(for originTile: PKTaijiTile) -> Criteria {
        Criteria(tileFilled: originTile.filled)
    }

    public func tile(_ tile: PKTaijiTile, matches criteria: Criteria) -> Bool {
        tile.filled == criteria.tileFilled
    }
}
