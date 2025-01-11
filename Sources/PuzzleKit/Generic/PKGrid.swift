//
//  PKGrid.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

/// A protocol representing a puzzle grid.
///
/// Puzzle grids are typically shaped as a rectangle or square with a determined width and height, and they can be
/// accessed via a specified coordinate (see ``PKGridCoordinate``).
public protocol PKGrid {
    /// The type that corresponds to an individual puzzle tile.
    associatedtype Tile

    /// The grid's width.
    var width: Int { get }

    /// The grid's height.
    var height: Int { get }

    /// Retrieves the tile at the specified grid coordinate.
    func tile(at coordinate: PKGridCoordinate) -> Tile?

    /// Retrieves the tile above the specified grid coordinate.
    func tile(above coordinate: PKGridCoordinate) -> Tile?

    /// Retrieves the tile before the specified grid coordinate.
    func tile(before coordinate: PKGridCoordinate) -> Tile?

    /// Retrieves the tile after the specified grid coordinate.
    func tile(after coordinate: PKGridCoordinate) -> Tile?

    /// Retrieves the tile below the specified grid coordinate.
    func tile(below coordinate: PKGridCoordinate) -> Tile?
}
