//
//  PKGridCoordinate.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 27-12-2024.
//

import Testing
@testable import PuzzleKit

@Suite("Grid Coordinate Tests")
struct PKGridCoordinateTests {
    @Test func gridCoordinateRotates() async throws {
        let gridCoordinate = PKGridCoordinate(x: 2, y: 2)

        let firstRotation = gridCoordinate.rotated()
        #expect(firstRotation == .init(x: -2, y: 2))

        let nextRotation = firstRotation.rotated()
        #expect(nextRotation == .init(x: -2, y: -2))

        let finalRotation = nextRotation.rotated()
        #expect(finalRotation == .init(x: 2, y: -2))

        let circled = finalRotation.rotated()
        #expect(circled == gridCoordinate)
    }
}
