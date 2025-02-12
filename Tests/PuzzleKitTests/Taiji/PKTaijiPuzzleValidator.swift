//
//  PKTaijiPuzzleValidator.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

import Testing
@testable import PuzzleKit

private typealias VError = PKTaijiPuzzleValidatorError

@Suite("Taiji Puzzle Validator")
struct PKTaijiPuzzleValidatorTests {
    @Test("Symbol lookup table constructs")
    func symbolLUTFillsCorrectly() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "6:0Cw+B2Y2Aw2Cw2222Dw2Sw+CDw0Bw+CCw0Tw22Sw02Uw2")
        #expect(puzzle.mechanics == .all)

        let validator = PKTaijiPuzzleValidator(puzzle: puzzle)
        #expect(validator.symbolLUT.flowers.count == 1)
        #expect(validator.symbolLUT.dotsPositive.count == 7)
        #expect(validator.symbolLUT.dotsNegative.count == 0)
        #expect(validator.symbolLUT.diamonds.count == 2)
        #expect(validator.symbolLUT.slashdashes.count == 2)
    }

    @Test("Region map constructs")
    func regionMapConstructs() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "6:0Cw+B2Y2Aw2Cw2222Dw2Sw+CDw0Bw+CCw0Tw22Sw02Uw2")
        let validator = PKTaijiPuzzleValidator(puzzle: puzzle)
        #expect(validator.regionMap.count == 24)

        #expect(validator.regionMap[.one] == 1)
        #expect(validator.regionMap[.init(x: 4, y: 1)] == 2)
        #expect(validator.regionMap[.init(x: 6, y: 2)] == 3)
        #expect(validator.regionMap[.init(x: 2, y: 4)] == 4)
        #expect(validator.regionMap[.init(x: 6, y: 4)] == 5)
    }

    @Test("Region map constructs - special case A")
    func regionMapConstructsSpecialCase1() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "3:Br2+B202+BBy2")
        let validator = PKTaijiPuzzleValidator(puzzle: puzzle)
        
        #expect(puzzle.tiles.count == 9)
        #expect(validator.regions.count == 3)
    }

    // MARK: - Flower constraints

    @Test("Flower constraints", arguments: [
        ("6:V02+B2X22W02+B2+G2+B202Y202Z2202+B20", nil),
        ("3:2Y2Cw60Aw2Sw0Sw+C", nil),
        ("6:V02+B2X22W02+B2+G2+B202Y222Z2202+B20", VError.invalidPetalCount(.init(x: 2, y: 5)))
    ])
    func validationFlowerConstraints(code: String, error: PKTaijiPuzzleValidatorError?) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        
        if let error {
            #expect(throws: error.self) {
                try puzzle.validate(options: .whatTheTaiji).get()
            }
        } else {
            #expect(throws: Never.self) {
                try puzzle.validate(options: .whatTheTaiji).get()
            }
        }

    }

    // MARK: - Diamond constraints

    @Test("Diamond constraints (WTT)", arguments: [
        ("3:Sw20Sw2Sw20Sw22Sw0Sw0", nil),
        ("3:Sw+BSw2Sw+BSw22Sw0Sw0", VError.invalidDiamondSize(1, 0))
    ])
    func validationDiamondConstraintsWTT(code: String, error: PKTaijiPuzzleValidatorError?) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        if let error {
            #expect(throws: error.self) {
                try puzzle.validate(options: .whatTheTaiji).get()
            }
        } else {
            #expect(throws: Never.self) {
                try puzzle.validate(options: .whatTheTaiji).get()
            }
        }
    }

    @Test("Diamond constraints (Base game, standalone)", arguments: [
        ("3:Sr+BSy+DSr+BSy0", nil),
        ("3:Sr+BSr+DSr+BSy0", VError.invalidDiamondSize(1, 0))
    ])
    func validationDiamondConstraintsStrictColors(code: String, error: PKTaijiPuzzleValidatorError?) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        if let error {
            #expect(throws: error.self) {
                try puzzle.validate(options: .baseGame).get()
            }
        } else {
            #expect(throws: Never.self) {
                try puzzle.validate(options: .baseGame).get()
            }
        }
    }
    
    // MARK: - Dot constraints

    @Test("Dots constraints (WTT)")
    func validationDotConstraintsWTT() async throws {
        let okDots = try PKTaijiPuzzle(decoding: "3:Dw20222Jw420Dw4")
        #expect(throws: Never.self) {
            try okDots.validate(options: .whatTheTaiji).get()
        }

        let notOkDots = try PKTaijiPuzzle(decoding: "3:Dw20222Jw4+BDw4")
        #expect(throws: PKTaijiPuzzleValidatorError.invalidRegionSize(1, 0)) {
            try notOkDots.validate(options: .whatTheTaiji).get()
        }
    }

    @Test("Dots constraints (Base game, standalone)", arguments: [
        ("3:Br2+B202+BBy2", nil),
        ("3:Ar20Jy2202Jr20Ay2", nil),
        ("3:Cr2+B222+BBy2", VError.invalidRegionSize(1, 0)),
        ("3:Ar20Jr2202Jy20Ay2", VError.invalidRegionSize(1, 0)),
    ])
    func validationDotConstraintsBaseGame(code: String, err: PKTaijiPuzzleValidatorError?) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        if let err {
            #expect(throws: err.self) {
                try puzzle.validate(options: .baseGame).get()
            }
        } else {
            #expect(throws: Never.self) {
                try puzzle.validate(options: .baseGame).get()
            }
        }
    }

    // MARK: - Slashdash constraints
    
    @Test("Slashdash constraints (WTT)")
    func validationSlashdashConstraintsWTT() async throws {
        let okSlashdash = try PKTaijiPuzzle(decoding: "6:644+B26Tw640Uw22644+B2")
        #expect(throws: Never.self) {
            try okSlashdash.validate(options: .whatTheTaiji).get()
        }

        let notOkSlashdash = try PKTaijiPuzzle(decoding: "4:02+CUw2Uw440Uw0Tw6+C60")
        #expect(throws: PKTaijiPuzzleValidatorError.invalidRegionShape) {
            try notOkSlashdash.validate(options: .whatTheTaiji).get()
        }
    }

    @Test("Slashdash checker mechanism when rotating")
    func validationSlashdashRotatable() async throws {
        let lhs = [Coord(x: 0, y: 0), Coord(x: -1, y: 0), Coord(x: -1, y: -1), Coord(x: -1, y: 1)]
        let rhs = [Coord(x: 0, y: 0), Coord(x: 1, y: 0), Coord(x: 1, y: 1), Coord(x: 1, y: -1)]
        let lhsOrigin = {
            var tile = PKTaijiTile.symbolic(.slashdash(rotates: false))
            tile.filled = true
            tile.state = .fixed
            return tile
        }()
        let rhsOrigin = {
            var tile = PKTaijiTile.symbolic(.slashdash(rotates: true))
            tile.filled = true
            return tile
        }()

        #expect(
            PKTaijiPuzzleValidator.slashdashRotates(lhs: lhs, rhs: rhs, lhsOrigin: lhsOrigin, rhsOrigin: rhsOrigin))
    }
}
