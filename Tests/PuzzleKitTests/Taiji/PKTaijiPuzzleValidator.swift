//
//  PKTaijiPuzzleValidator.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

import Testing
@testable import PuzzleKit

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

    @Test("Flower constraints")
    func validationFlowerConstraints() async throws {
        let okFlowers = try PKTaijiPuzzle(decoding: "6:V02+B2X22W02+B2+G2+B202Y202Z2202+B20")
        let okValid = okFlowers.validate()
        switch okValid {
        case .success(_):
            break
        case .failure(let error):
            Issue.record(error, "Validation failed.")
        }

        let notOkFlowers = try PKTaijiPuzzle(decoding: "6:V02+B2X22W02+B2+G2+B202Y222Z2202+B20")
        let notOkValidation = notOkFlowers.validate()
        switch notOkValidation {
        case .success(_):
            Issue.record("Validation passed incorrectly.")
        case .failure(let error):
            #expect(error == PKTaijiPuzzleValidatorError.invalidPetalCount(.init(x: 2, y: 5)))
        }
    }

    @Test("Diamond constraints")
    func validationDiamondConstraints() async throws {
        let okDiamonds = try PKTaijiPuzzle(decoding: "3:Sw20Sw2Sw20Sw22Sw0Sw0")
        let okValid = okDiamonds.validate()
        switch okValid {
        case .success(_):
            break
        case .failure(let error):
            Issue.record(error, "Validation failed.")
        }

        let notOkDiamonds = try PKTaijiPuzzle(decoding: "3:Sw+BSw2Sw+BSw22Sw0Sw0")
        let notOkValid = notOkDiamonds.validate()
        switch notOkValid {
        case .success(_):
            Issue.record("Validation passed incorrectly.")
        case .failure(let error):
            #expect(error == PKTaijiPuzzleValidatorError.invalidDiamondSize(1, 0))
        }
    }

    @Test("Dots constraints")
    func validationDotConstraints() async throws {
        let okDots = try PKTaijiPuzzle(decoding: "3:Dw20222Jw420Dw4")
        let validator = okDots.validate()
        switch validator {
        case .success(_):
            break
        case .failure(let error):
            Issue.record(error, "Validation failed.")
        }

        let notOkDots = try PKTaijiPuzzle(decoding: "3:Dw20222Jw4+BDw4")
        let notOkValid = notOkDots.validate()
        switch notOkValid {
        case .success(_):
            Issue.record("Validation passed incorrectly.")
        case .failure(let error):
            #expect(error == .invalidRegionSize(1, 0))
        }
    }

    @Test("Slashdash constraints")
    func validationSlashdashConstraints() async throws {
        let okSlashdash = try PKTaijiPuzzle(decoding: "6:644+B26Tw640Uw22644+B2")
        let validator = okSlashdash.validate()
        switch validator {
        case .success(_):
            break
        case .failure(let error):
            Issue.record(error, "Validation failed.")
        }

//        let notOkSlashdash = try PKTaijiPuzzle(decoding: "4:02+CUw2Uw440Uw0Tw6+C60")
//        let notOkValidator = notOkSlashdash.validate()
//        switch notOkValidator {
//        case .success(_):
//            Issue.record("Validation passed incorrectly.")
//        case .failure(let error):
//            #expect(error == .invalidRegionShape)
//        }
    }
}
