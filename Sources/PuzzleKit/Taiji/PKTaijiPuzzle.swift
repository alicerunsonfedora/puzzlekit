//
//  PKTaijiPuzzle.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 21-12-2024.
//

import Foundation

// MARK: - Main puzzle structure

/// A representation of a Taiji puzzle.
public struct PKTaijiPuzzle: Equatable, Sendable {
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
        self.tiles = tiles
        self.width = boardWidth
        self.mechanics = mechanics
    }
}

public extension PKTaijiPuzzle {
    /// Validates the current puzzle, checking for any unsatisfied constraints.
    /// - Returns: The result from validation.
    func validate(options: PKTaijiPuzzleValidator.Options = []) -> PKTaijiPuzzleValidator.ValidationResult {
        let validator = PKTaijiPuzzleValidator(puzzle: self, options: options)
        return validator.validate()
    }
}

// MARK: - Codable Conformance

extension PKTaijiPuzzle: Codable {
    /// Creates a Taiji puzzle from a decoder, interpreting the input as a puzzle code string.
    ///
    /// This initializer is typically used in scenarios where the puzzle might be decoded from a larger structure, such
    /// as JSON or a window declaration in SwiftUI.
    ///
    /// ```swift
    /// let json =
    ///     """
    ///     {
    ///         "name": "Geschlossene Erinnerungen",
    ///         "author": "Lorelei Weiss",
    ///         "puzzle": "6:644+B26Tw640Uw22644+B2"
    ///     }
    ///     """
    ///
    /// let data = json.data(using: .utf8)!
    /// let decoder = JSONDecoder()
    /// let result = try decoder.decode(MyPuzzleFile.self, from: data)
    /// ```
    /// 
    /// - Parameter decoder: The decoder to retrieve the puzzle code from.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let code = try container.decode(String.self)

        let (boardWidth, tiles, mechanics) = try PKTaijiDecoder.decode(from: code)
        self.tiles = tiles
        self.width = boardWidth
        self.mechanics = mechanics
    }

    /// Encodes the Taiji puzzle into an encoder as a puzzle code string.
    ///
    /// This method is typically called within Codable encoders to encode the data into other formats, such as JSON.
    ///
    /// ```swift
    /// struct MyPuzzleFile: Codable {
    ///     var name: String
    ///     var author: String
    ///     var puzzle: PKTaijiPuzzle
    /// }
    /// 
    /// let pzl = MyPuzzleFile(...)
    /// let encoder = JSONEncoder()
    /// encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    /// let json = try encoder.encode(pzl)
    /// ```
    /// - Parameter encoder: The encoder to encode the puzzle into.
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        let code = PKTaijiEncoder.encode(self)
        try container.encode(code)
    }
}

// MARK: - Grid Conformances

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

// MARK: - Flood Fill Conformance

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

// MARK: - Stretching Conformance

extension PKTaijiPuzzle: PKGridStretchable {
    public func appendingColumn() -> PKTaijiPuzzle {
        var copy = self
        copy.width += 1

        for i in 1...self.height {
            let index = i * self.width
            copy.tiles.insert(.empty(), at: index + 1)
        }
        
        return copy
    }
    
    public func appendingRow() -> PKTaijiPuzzle {
        var copy = self
        copy.tiles += Array(repeating: .empty(), count: width)
        return copy
    }
    
    public func removingLastColumn() -> PKTaijiPuzzle {
        var copy = self
        copy.width -= 1
        copy.tiles = []

        var column = 1
        for tile in self.tiles {
            if column > copy.width {
                column = 1
                continue
            }
            copy.tiles.append(tile)
            column += 1
        }
        
        return copy
    }
    
    public func removingLastRow() -> PKTaijiPuzzle {
        var copy = self
        copy.tiles.removeLast(copy.width)
        return copy
    }
}
