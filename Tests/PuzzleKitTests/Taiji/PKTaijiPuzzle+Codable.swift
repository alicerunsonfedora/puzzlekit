//
//  PKTaijiPuzzle+Codable.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 11-01-2025.
//

import Foundation
import Testing
@testable import PuzzleKit

struct PuzzleJSON: Codable {
    var name: String
    var puzzle: PKTaijiPuzzle
}

@Suite("Taiji puzzle codability")
struct PKTaijiPuzzleCodableTests {
    @Test("Decoding works correctly")
    func decoderDecodesPuzzle() async throws {
        let json =
            """
            {
                "name": "I Decoded",
                "puzzle": "6:644+B26Tw640Uw22644+B2"
            }
            """
        guard let data = json.data(using: .utf8) else {
            Issue.record("Data failure")
            return
        }
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PuzzleJSON.self, from: data)
        
        #expect(decoded.name == "I Decoded")
        #expect(decoded.puzzle.width == 6)
    }
    
    @Test("Encoding works correctly")
    func encoderEncodesPuzzle() async throws {
        let expected =
            """
            {
              "name" : "I Encoded",
              "puzzle" : "3:+I"
            }
            """
        let pzl = PuzzleJSON(name: "I Encoded", puzzle: .init(size: CGSize(width: 3, height: 3)))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let json = try encoder.encode(pzl)
        let jsonString = String(data: json, encoding: .utf8)
        
        #expect(jsonString == expected)
    }
}
