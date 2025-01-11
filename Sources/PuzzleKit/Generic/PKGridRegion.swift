//
//  PKGridRegion.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 24-12-2024.
//

/// A structure representing an individual region in a grid.
public struct PKGridRegion: Hashable, Equatable, Identifiable {
    /// The regions unique identifier.
    public var id: Int

    /// The size of the region.
    public var size: Int { coordinates.count }

    /// The coordinates that are members of this region.
    public var members: Set<PKGridCoordinate> {
        Set(coordinates)
    }

    private var coordinates: [PKGridCoordinate]

    /// Creates a region with a given array of coordinates and an ID.
    /// - Parameter coordinates: The coordinates that exist in the region.
    /// - Parameter id: The region's unique identifier.
    public init(coordinates: [PKGridCoordinate], identifiedBy id: Int) {
        self.coordinates = coordinates
        self.id = id
    }

    /// Creates a region with a given set of coordinates and an ID.
    /// - Parameter coordinates: The coordinates that exist in the region.
    /// - Parameter id: The region's unique identifier.
    public init(coordinates: Set<PKGridCoordinate>, identifiedBy id: Int) {
        self.coordinates = Array(coordinates)
        self.id = id
    }

    /// Returns whether a given coordinate exists within this region.
    public func contains(_ coordinate: PKGridCoordinate) -> Bool {
        coordinates.contains(coordinate)
    }

    /// Returns an array of coordinates that describe the shape of the region, relative to an origin coordinate.
    /// - Parameter origin: The origin tile to reference. If none is provided, the first tile in the region will be used.
    public func shape(relativeTo origin: PKGridCoordinate? = nil) -> [PKGridCoordinate] {
        guard let realOrigin = origin ?? coordinates.first else { return [] }
        return coordinates.map { $0 - realOrigin }
    }
}

public extension PKGridRegion {
    /// Creates a region by flood-filling a grid, originating from an origin coordinate.
    /// - Parameter origin: The origin tile to start flood-filling from.
    /// - Parameter grid: The grid to flood-fill into.
    /// - Parameter id: The region's unique identifier.
    init<Grid>(floodFillingFrom origin: PKGridCoordinate, in grid: Grid, identifiedBy id: Int) where Grid: PKGrid & PKFloodFillable {
        let region = grid.findFloodFilledRegion(startingAt: origin)
        coordinates = Array(region)
        self.id = id
    }
}
