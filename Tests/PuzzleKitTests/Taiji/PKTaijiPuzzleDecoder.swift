import Testing
@testable import PuzzleKit


@Suite("Taiji Puzzle Decoding")
struct TaijiPuzzleDecoderTests {
    struct DecoderSpecialAttrsArguments {
        var code: String
        var expectedState: PKTaijiTileState
        var filled: Bool
    }
    
    @Test("Basic Puzzle Decodes (One Tile)",
          arguments: zip([
            "1:0",
            "1:Dw0",
            "1:Rw0",
            "1:Sw0",
            "1:Tw0",
            "1:Uw0",
            "1:Xw0"
          ], [
            PKTaijiTile.empty(),
            PKTaijiTile.symbolic(.dot(value: 4, additive: true)),
            PKTaijiTile.symbolic(.dot(value: 9, additive: false)),
            PKTaijiTile.symbolic(.diamond),
            PKTaijiTile.symbolic(.slashdash(rotates: false)),
            PKTaijiTile.symbolic(.slashdash(rotates: true)),
            PKTaijiTile.symbolic(.flower(petals: 2))
          ])
    )
    func decoderBasicExample(code: String, tile: PKTaijiTile) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        #expect(puzzle.source == code)
        #expect(puzzle.width == 1)
        #expect(puzzle.tiles.count == 1)
        
        if let firstTile = puzzle.tiles.first {
            #expect(firstTile == tile)
        }
    }

    @Test("Puzzle with Shorthand Decodes", arguments: zip(["3:+I", "2:-Z"], [9, 26]))
    func decoderArrayFill(code: String, expectedCount: Int) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        #expect(puzzle.source == code)
        #expect(puzzle.tiles.count == expectedCount)
    }

    @Test("Puzzle with Colors Decodes", arguments: zip(["1:Ak0", "1:Ur0"], [PKTaijiSymbolColor.white, PKTaijiSymbolColor.red]))
    func decoderWithColorAttributes(code: String, expectedColor: PKTaijiSymbolColor) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        #expect(puzzle.source == code)
        #expect(puzzle.tiles.count == 1)

        if let firstTile = puzzle.tiles.first {
            #expect(firstTile.color == expectedColor)
        }
    }

    @Test("Puzzle with Special Attributes Decodes",
          arguments: [
            DecoderSpecialAttrsArguments(code: "1:0", expectedState: .normal, filled: false),
            DecoderSpecialAttrsArguments(code: "1:2", expectedState: .normal, filled: true),
            DecoderSpecialAttrsArguments(code: "1:4", expectedState: .fixed, filled: false),
            DecoderSpecialAttrsArguments(code: "1:6", expectedState: .fixed, filled: true),
            DecoderSpecialAttrsArguments(code: "1:8", expectedState: .invisible, filled: false),
            DecoderSpecialAttrsArguments(code: "1:Tw4", expectedState: .fixed, filled: false)
          ])
    func decoderWithSpecialAttrs(args: DecoderSpecialAttrsArguments) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: args.code)
        #expect(puzzle.source == args.code)
        #expect(puzzle.tiles.count == 1)

        if let firstTile = puzzle.tiles.first {
            #expect(firstTile.state == args.expectedState)
            #expect(firstTile.filled == args.filled)
        }
    }

    @Test("Puzzle with Invalid Width Throws")
    func decoderThrowsInvalidWidth() async throws {
        #expect(throws: PKTaijiPuzzleDecoderError.invalidBoardWidth) {
            try PKTaijiPuzzle(decoding: "1000000000000000000000000000000:0")
        }
    }

    @Test("Puzzle with Invalid Array Fill Throws")
    func decoderThrowsInvalidArrayFill() async throws {
        #expect(throws: PKTaijiPuzzleDecoderError.invalidPrefillWidth) {
            try PKTaijiPuzzle(decoding: "27:+!")
        }
    }

    @Test("Complex Puzzle Decodes")
    func decoderDecodesComplexPuzzle() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "6:0Cw+CY0Aw0Cw+DDw0Sw+CDw0Bw+CCw0Tw+BSw+BUw0")
        #expect(puzzle.mechanics == .all)
        
        #expect(puzzle.tiles == [
            // Row 1
            .empty(),
            .symbolic(.dot(value: 3, additive: true)),
            .empty(),
            .empty(),
            .symbolic(.flower(petals: 3)),
            .symbolic(.dot(value: 1, additive: true)),

            // Row 2
            .symbolic(.dot(value: 3, additive: true)),
            .empty(),
            .empty(),
            .empty(),
            .symbolic(.dot(value: 4, additive: true)),
            .symbolic(.diamond),

            // Row 3
            .empty(),
            .empty(),
            .symbolic(.dot(value: 4, additive: true)),
            .symbolic(.dot(value: 2, additive: true)),
            .empty(),
            .empty(),

            // Row 4
            .symbolic(.dot(value: 3, additive: true)),
            .symbolic(.slashdash(rotates: false)),
            .empty(),
            .symbolic(.diamond),
            .empty(),
            .symbolic(.slashdash(rotates: true))
        ])
    }

    @Test("Complex Puzzle Decodes - Special Case 1")
    func decoderDecodesComplexPuzzleSpecialCase_1() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "4:222+BUw2Uw440Uw0Tw6+B262")
        #expect(puzzle.mechanics == .slashdash)
        
        #expect(puzzle.tiles == [
            // Row 1
            .emptyFilled(),
            .emptyFilled(),
            .emptyFilled(),
            .empty(),

            // Row 2
            .empty(),
            {
                var tile = PKTaijiTile.symbolic(.slashdash(rotates: true))
                tile.filled = true
                return tile
            }(),
            {
                var tile = PKTaijiTile.symbolic(.slashdash(rotates: true))
                tile.state = .fixed
                return tile
            }(),
            .init(state: .fixed),

            // Row 3
            .empty(),
            .symbolic(.slashdash(rotates: true)),
            {
                var tile = PKTaijiTile.symbolic(.slashdash(rotates: false))
                tile.state = .fixed
                tile.filled = true
                return tile
            }(),
            .empty(),

            // Row 4
            .empty(),
            .emptyFilled(),
            {
                var tile = PKTaijiTile(state: .fixed)
                tile.filled = true
                return tile
            }(),
            .emptyFilled()
        ])
    }

    @Test("Complex Puzzle Decodes - Special Case 2")
    func decoderDecodesComplexPuzzleSpecialCase_2() async throws {
        let puzzle = try PKTaijiPuzzle(decoding: "6:644+B26Tw640Uw22644+B2")
        #expect(puzzle.mechanics == .slashdash)
        #expect(puzzle.tiles.count == 18)

        let slashdashes = puzzle.tiles.filter { tile in
            if case .slashdash = tile.symbol { return true }
            return false
        }.map(\.symbol)
        let expected = Set([
            PKTaijiTileSymbol.slashdash(rotates: true),
            PKTaijiTileSymbol.slashdash(rotates: false)
        ])
        #expect(Set(slashdashes) == expected)
    }
}

