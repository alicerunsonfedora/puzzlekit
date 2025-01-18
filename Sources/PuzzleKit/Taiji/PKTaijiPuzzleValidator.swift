//
//  PKTaijiPuzzleValidator.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

import Foundation

public enum PKTaijiPuzzleValidatorError: Sendable, Equatable, Error {
    case invalidPetalCount(PKGridCoordinate)
    case invalidDiamondSize(Int, Int)
    case invalidRegionSize(Int, Int)
    case invalidRegionShape
    case regionShapeMapInvalid
}

/// A validator for Taiji puzzles.
public class PKTaijiPuzzleValidator {
    /// A type representing the validation result.
    public typealias ValidationResult = Result<Void, PKTaijiPuzzleValidatorError>

    /// A structure representing the options the validator can accept.
    public struct Options: OptionSet, Sendable {
        /// The raw value representing the options available.
        public var rawValue: Int

        /// Ignore color mechanics when validating.
        public static let ignoresColor = Options(rawValue: 1 << 0)

        /// Allow color mechanics to match against any type of symbol when necessary.
        public static let colorsMatchAnySymbols = Options(rawValue: 1 << 1)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    struct SymbolLUT {
        var diamonds = [PKGridCoordinate]()
        var dotsPositive = [PKGridCoordinate]()
        var dotsNegative = [PKGridCoordinate]()
        var slashdashes = [PKGridCoordinate]()
        var flowers = [PKGridCoordinate]()
    }

    var options: Options
    var puzzle: PKTaijiPuzzle
    var symbolLUT = SymbolLUT()
    var regionMap = [PKGridCoordinate: Int]()
    var regions = [Int: PKGridRegion]()

    var totalRegions: Int { return regions.count }

    public init(puzzle: PKTaijiPuzzle, options: Options = []) {
        self.puzzle = puzzle
        self.options = options

        var currentRegion = 1
        self.regionMap = [PKGridCoordinate: Int]()
        self.regions = [:]

        for (index, tile) in puzzle.tiles.enumerated() {
            let tileCoordinate = index.toCoordinate(wrappingAround: puzzle.width)
            if regionMap[tileCoordinate] == nil {
                let region = PKGridRegion(floodFillingFrom: tileCoordinate, in: puzzle, identifiedBy: currentRegion)
                for coordinate in region.members {
                    regionMap[coordinate] = currentRegion
                }
                self.regions[currentRegion] = region
                currentRegion += 1
            }
            self.updateSymbolLUT(index: index, tile: tile)
        }
    }

    public func validate() -> ValidationResult {
        for flower in symbolLUT.flowers {
            let result = flowerConstraintsSatisfied(for: flower)
            if !result {
                return .failure(.invalidPetalCount(flower))
            }
        }

        for region in 1...totalRegions {
            let diamonds = diamondConstraintsSatisfied(for: region)
            if !diamonds {
                return .failure(.invalidDiamondSize(region, 0))
            }

            let dots = dotConstraintsSatisfied(for: region)
            if !dots {
                return .failure(.invalidRegionSize(region, 0))
            }
        }

        let response = validateSlashdashConstraints()
        switch response {
        case .success:
            break
        case .failure:
            return response
        }

        return .success(())
    }

    private func updateSymbolLUT(index: Int, tile: PKTaijiTile) {
        let coordinate = index.toCoordinate(wrappingAround: puzzle.width)
        switch tile.symbol {
        case .flower:
            symbolLUT.flowers.append(coordinate)
        case .dot(_, let additive):
            if additive {
                symbolLUT.dotsPositive.append(coordinate)
            } else {
                symbolLUT.dotsNegative.append(coordinate)
            }
        case .diamond:
            symbolLUT.diamonds.append(coordinate)
        case .slashdash:
            symbolLUT.slashdashes.append(coordinate)
        case nil:
            return
        }
    }

    private func flowerConstraintsSatisfied(for coordinate: PKGridCoordinate) -> Bool {
        guard let tile = puzzle.tile(at: coordinate), case .flower(let petals) = tile.symbol else { return true }
        let flowerFilled = tile.filled

        let neighbors = [puzzle.tile(above: coordinate),
                         puzzle.tile(before: coordinate),
                         puzzle.tile(after: coordinate),
                         puzzle.tile(below: coordinate)]

        let totalFilled = neighbors.count { tile in
            guard let tile else { return false }
            return tile.filled == flowerFilled
        }

        return totalFilled == petals
    }

    private func diamondConstraintsSatisfied(for region: Int) -> Bool {
        if options.contains(.ignoresColor) {
            let diamondsInRegion = symbolLUT.diamonds.filter { diamond in
                guard let diamondRegion = regionMap[diamond] else { return false }
                return diamondRegion == region
            }
            return diamondsInRegion.count == 2 || diamondsInRegion.count == 0
        }

        let diamondsInRegion = symbolLUT.diamonds.filter { diamond in
            guard let diamondRegion = regionMap[diamond] else { return false }
            return diamondRegion == region
        }

        var colorMapping = [PKTaijiSymbolColor: Int]()
        for diamond in diamondsInRegion {
            guard let tile = puzzle.tile(at: diamond), let color = tile.color else { continue }
            colorMapping[color, default: 0] += 1
        }

        if options.contains(.colorsMatchAnySymbols) {
            // TODO: Account for flowers and other symbols in this region with colors.
        }

        return colorMapping.allSatisfy { (_, count) in
            count == 2 || count == 0
        }
    }

    private func dotConstraintsSatisfied(for region: Int) -> Bool {
        let plusDots = symbolLUT.dotsPositive.filter { dot in
            guard let dotRegion = regionMap[dot] else { return false }
            return dotRegion == region
        }.reduce(0) { accum, dotCoord in
            sumDotTile(accum: accum, coordinate: dotCoord, additive: true)
        }
        let minusDots = symbolLUT.dotsNegative.filter { dot in
            guard let dotRegion = regionMap[dot] else { return false }
            return dotRegion == region
        }.reduce(0) { accum, dotCoord in
            sumDotTile(accum: accum, coordinate: dotCoord, additive: false)
        }
        let expectedSize = plusDots - minusDots
        if expectedSize == 0 { return true }

        let regionData = regions[region]
        return expectedSize == regionData?.size
    }

    private func sumDotTile(accum: Int, coordinate: PKGridCoordinate, additive: Bool) -> Int {
        guard let tile = puzzle.tile(at: coordinate) else { return accum }
        guard case .dot(let value, additive: additive) = tile.symbol else { return accum }
        return accum + value
    }

    private func validateSlashdashConstraints() -> ValidationResult {
        guard !symbolLUT.slashdashes.isEmpty else { return .success(()) }
        let regions = symbolLUT.slashdashes
            .map { coordinate in
                let regionID = self.regionMap[coordinate] ?? 1
                return self.regions[regionID]
            }
        let regionShapes = regions.enumerated().map { (index, regionDatum) in
            regionDatum?.shape(relativeTo: symbolLUT.slashdashes[index]) ?? []
        }

        guard let expectedShape = regionShapes.first,
              let baseTile = puzzle.tile(at: symbolLUT.slashdashes.first ?? .one) else {
            return .failure(.regionShapeMapInvalid)
        }
        let expectedShapeRotates = baseTile.symbol == .slashdash(rotates: true)
        for (index, shape) in regionShapes.dropFirst().enumerated() {
            let sOrigin = symbolLUT.slashdashes[index+1]
            guard let origin = puzzle.tile(at: sOrigin) else { continue }

            if expectedShapeRotates || origin.symbol == .slashdash(rotates: true) {
                let result = Self.slashdashRotates(
                    lhs: expectedShape,
                    rhs: shape,
                    lhsOrigin: baseTile,
                    rhsOrigin: origin)
                if !result {
                    return .failure(.invalidRegionShape)
                }
            } else {
                let matches = Set(shape) == Set(expectedShape)
                if !matches {
                    return .failure(.invalidRegionShape)
                }
            }
        }
        return .success(())
    }

    static func slashdashRotates(
        lhs: [PKGridCoordinate],
        rhs: [PKGridCoordinate],
        lhsOrigin: PKTaijiTile,
        rhsOrigin: PKTaijiTile
    ) -> Bool {

        guard case let .slashdash(lhsRotates) = lhsOrigin.symbol,
              case let .slashdash(rhsRotates) = rhsOrigin.symbol else {
            return false
        }

        var rotatingShape: [PKGridCoordinate]
        var staticShape: [PKGridCoordinate]

        switch (lhsRotates, rhsRotates) {
        case (true, false):
            rotatingShape = lhs
            staticShape = rhs
        case (false, true):
            rotatingShape = rhs
            staticShape = lhs
        default:
            rotatingShape = rhs
            staticShape = lhs
        }

        var foundMatch = false
        for _ in 1...4 {
            if Set(rotatingShape) == Set(staticShape) {
                foundMatch = true
                break
            }
            rotatingShape = rotatingShape.map { $0.rotated() }
        }
        return foundMatch
    }
}

public extension PKTaijiPuzzleValidator.Options {
    /// The typical validator rules associated with the base game.
    static let baseGame: Self = [.colorsMatchAnySymbols]

    /// The typical validator rules associated with the "What the Taiji?!" spinoff.
    ///
    /// Due to technical limitations with the Playdate, this validator style ignores some aspects of typical Taiji
    /// puzzles, such as the lack of color.
    static let whatTheTaiji: Self = [.ignoresColor]
}
