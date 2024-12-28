//
//  PKTaijiPuzzleEncoder.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 27-12-2024.
//

import Testing
@testable import PuzzleKit

@Suite("Taiji Puzzle Encoder")
struct PKTaijiPuzzleEncoderTests {
    @Test("Taiji puzzle encodes",
          arguments: [
            "4:02+CUw2Uw440Uw0Tw6+C60",
            "6:0Cw+CY0Aw0Cw+DDw0Sw+CDw0Bw+CCw0Tw+BSw+BUw0",
            "8:+JAw0Hw4Dw6Gw+K",
            "6:W+EW+DUw+EY0Y+EY0Y+EUw+DW+EW0",

            // TODO: Investigate this last case below...
            "9:Ew+DBw+BTw+ECw+DTw+FTw+MBw+BDw4+CTw+CBw+BTw0Cw6+G"
          ])
    func taijiPuzzleEncodes(code: String) async throws {
        let puzzle = try PKTaijiPuzzle(decoding: code)
        let enco = String(encoding: puzzle)
        #expect(enco == code)
    }
}
