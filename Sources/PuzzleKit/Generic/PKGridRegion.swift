//
//  PKGridRegion.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 24-12-2024.
//

public struct PKGridRegion: Hashable, Equatable, Identifiable {
    public var id: Int

    public var size: Int { coordinates.count }

    private var coordinates: [PKGridCoordinate]

    public init(coordinates: [PKGridCoordinate], identifiedBy id: Int) {
        self.coordinates = coordinates
        self.id = id
    }

    public init(coordinates: Set<PKGridCoordinate>, identifiedBy id: Int) {
        self.coordinates = Array(coordinates)
        self.id = id
    }

    public func contains(_ coordinate: PKGridCoordinate) -> Bool {
        coordinates.contains(coordinate)
    }

    public func shape(relativeTo origin: PKGridCoordinate? = nil) -> [PKGridCoordinate] {
        guard let realOrigin = origin ?? coordinates.first else { return [] }
        return coordinates.map { $0 - realOrigin }
    }
}
