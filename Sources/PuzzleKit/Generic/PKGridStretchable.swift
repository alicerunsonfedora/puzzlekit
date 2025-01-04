//
//  PKGridStretchable.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 03-01-2025.
//

/// A protocol for grids whose bounds can be stretched out by inserting or removing rows and columns.
public protocol PKGridStretchable: PKGrid {
    /// Appends a column to the grid.
    func appendingColumn() -> Self

    /// Appends a row to the grid.
    func appendingRow() -> Self

    /// Removes the last column from the grid.
    func removingLastColumn() -> Self

    /// Removes the last row from the grid.
    func removingLastRow() -> Self
}
