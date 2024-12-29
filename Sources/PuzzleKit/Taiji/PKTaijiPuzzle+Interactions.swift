//
//  PKTaijiPuzzle+Interactions.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

public extension PKGridCoordinate {
    /// Converts the coordinate into an array index, relative to a Taiji puzzle board.
    /// - Parameter taijiPuzzle: The puzzle to retrieve an index for.
    /// - Returns: An array index, or -1 if the coordinate is out of bounds relative to the grid's width and count.
    func toIndex(relativeTo taijiPuzzle: PKTaijiPuzzle) -> Int {
        self.toIndex(wrappingAround: taijiPuzzle.width, in: taijiPuzzle.tiles.count)
    }
}

public extension [PKTaijiTile].Index {
    /// Converts a tile index into a grid coordinate, wrapping around a board width.
    /// - Parameter width: The width of the puzzle board.
    /// - Returns: The grid coordinate representing the tile at the original index.
    func toCoordinate(wrappingAround width: Int) -> PKGridCoordinate {
        if self == 0 { return .init(x: 1, y: 1) }

        var row = 1
        var column = 1
        for _ in 0..<self {
            if column == width {
                column = 1
                row += 1
                continue
            }
            column += 1
        }
        return .init(x: column, y: row)
    }
}

public extension PKTaijiPuzzle {
    func flippingTile(at coordinate: PKGridCoordinate) -> PKTaijiPuzzle {
        let index = coordinate.toIndex(relativeTo: self)
        guard index > -1, index < tiles.count else { return self }
        var newCopy = self
        newCopy.tiles[index].filled.toggle()
        return newCopy
    }
}
