//
//  PKFloodFillable.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

/// A protocol for grids that support flood filling.
public protocol PKFloodFillable {
    /// The type that corresponds to an individual tile.
    associatedtype Tile: Hashable

    /// The type that represents the criteria that quality for flood fill.
    associatedtype Criteria: Equatable

    /// Determines whether a given tile matches the specified criteria.
    /// - Parameter tile: The tile to match with the criteria.
    /// - Parameter criteria: The criteria to match against.
    /// - Returns: Whether the tile matches the given criteria.
    func tile(_ tile: Tile, matches criteria: Criteria) -> Bool

    /// Retrieves the criteria for a given origin tile.
    /// - Parameter originTile: The tile to generate criteria from.
    func getCriteria(for originTile: Tile) -> Criteria
}

extension PKGrid where Self: PKFloodFillable {
    /// Retrieves the region the specified origin tile resides in, using the flood fill algorithm.
    /// - Parameter origin: The origin tile to get the region of.
    /// - Returns: A set of tiles that reside within the same region as the origin tile.
    public func findFloodFilledRegion(startingAt origin: PKGridCoordinate) -> Set<PKGridCoordinate> {
        var stack = [origin]
        var visited = Set<PKGridCoordinate>()
        var region = Set<PKGridCoordinate>()
        var criterion: Criteria?

        while !stack.isEmpty {
            guard let top = stack.popLast(), let tile = self.tile(at: top) else {
                break
            }

            if let criterion {
                if self.tile(tile, matches: criterion) { region.insert(top) }
            } else {
                criterion = getCriteria(for: tile)
                region.insert(top)
            }
            visited.insert(top)

            guard let criterion else { break }

            let up = top.above()
            if !visited.contains(up), let uTile = self.tile(at: up), self.tile(uTile, matches: criterion) {
                stack.append(up)
            }

            let left = top.before()
            if !visited.contains(left), let lTile = self.tile(at: left), self.tile(lTile, matches: criterion) {
                stack.append(left)
            }

            let right = top.after(clampingTo: width)
            if !visited.contains(right), let rTile = self.tile(at: right), self.tile(rTile, matches: criterion) {
                stack.append(right)
            }

            let down = top.below(clampingTo: height)
            if !visited.contains(down), let dTile = self.tile(at: down), self.tile(dTile, matches: criterion) {
                stack.append(down)
            }
        }

        return region
    }
}
