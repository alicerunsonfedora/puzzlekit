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
    /// Flips the filled state of the tile at a specified coordinate.
    /// - Parameter coordinate: The coordinate of the tile to flip.
    /// - Returns: A copy of the puzzle board with the tile flipped.
    func flippingTile(at coordinate: PKGridCoordinate) -> PKTaijiPuzzle {
        let index = coordinate.toIndex(relativeTo: self)
        guard (tiles.startIndex...tiles.endIndex).contains(index) else { return self }
        var newCopy = self
        newCopy.tiles[index].filled.toggle()
        return newCopy
    }

    /// Replaces the symbol at a specified coordinate with a new symbol.
    /// - Parameter coordinate: The coordinate of the tile to replace its symbol.
    /// - Parameter symbol: The symbol that the tile should be replaced with.
    /// - Returns: A copy of the puzzle with the tile taking on the new symbol.
    func replacingSymbol(at coordinate: PKGridCoordinate, with symbol: PKTaijiTileSymbol?) -> PKTaijiPuzzle {
        let index = coordinate.toIndex(relativeTo: self)
        guard (tiles.startIndex...tiles.endIndex).contains(index) else { return self }
        var newCopy = self
        let oldTile = self.tiles[index]
        newCopy.tiles[index] = PKTaijiTile(state: oldTile.state, symbol: symbol, color: oldTile.color)
        return newCopy
    }

    /// Updates the state of the tile at a specified coordinate.
    /// - Parameter coordinate: The coordinate of the tile to update its state.
    /// - Parameter newState: The new state the tile will take on.
    /// - Returns: A copy of the puzzle with the tile taking on the new state.
    func applyingState(at coordinate: PKGridCoordinate, with newState: PKTaijiTileState) -> PKTaijiPuzzle {
        let index = coordinate.toIndex(relativeTo: self)
        guard (tiles.startIndex...tiles.endIndex).contains(index) else { return self }
        var newCopy = self
        let oldTile = self.tiles[index]
        newCopy.tiles[index] = PKTaijiTile(state: newState, symbol: oldTile.symbol, color: oldTile.color)
        return newCopy
    }
}
