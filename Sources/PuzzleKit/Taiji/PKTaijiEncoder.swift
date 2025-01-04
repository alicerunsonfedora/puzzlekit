//
//  PKTaijiEncoder.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 27-12-2024.
//

extension PKTaijiTile {
    typealias Constants = PKTaijiDecoder.Constants

    func encode() -> String {
        var tileCode = ""
        if let symbol = self.symbol {
            let character = switch symbol {
            case .flower(let petals):
                Constants.flowers.character(at: petals)
            case .dot(let value, let additive):
                (additive ? Constants.dotsPositive : Constants.dotsNegative).character(at: value - 1)
            case .diamond:
                Constants.diamond
            case .slashdash(let rotates):
                rotates ? Constants.slash : Constants.dash
            }
            tileCode += String(character)

            let color = Constants.colorMap.first { (key: Character, value: PKTaijiSymbolColor) in
                value == self.color
            }?.key
            if let color {
                switch symbol {
                case .flower:
                    break
                default:
                    tileCode += String(color)
                }
            }
        }

        var stateAttribute = "0"
        switch (self.state) {
        case .invisible:
            stateAttribute = "8"
        case .fixed:
            stateAttribute = self.filled ? "6" : "4"
        case .normal:
            stateAttribute = self.filled ? "2" : "0"
        }
        tileCode += stateAttribute

        return tileCode
    }
}

enum PKTaijiEncoder {
    typealias Constants = PKTaijiDecoder.Constants
    
    static func encode(_ puzzle: PKTaijiPuzzle) -> String {
        let prefix = "\(puzzle.width):"
        var encodedString = puzzle.tiles.map { $0.encode() }.reduce("", +)

        // NOTE: Reverse the contents of the range, because we want to go top-down instead of bottom-up.
        for i in (2...26).reversed() {
            guard let character = String(charCode: 64 + i) else { continue }
            
            encodedString = encodedString
                .replacingOccurrences(of: String(repeating: "0", count: i), with: "+" + character)
                .replacingOccurrences(of: String(repeating: "8", count: i), with: "-" + character)
        }

        return prefix + encodedString
    }
}

public extension String {
    /// Creates a string by encoding a given Taiji puzzle.
    /// - Parameter puzzle: The puzzle to encode into a string.
    /// - SeeAlso: For more information on the encoding format, refer to <doc:Taiji#Code-representation>.
    init(encoding puzzle: PKTaijiPuzzle) {
        self = PKTaijiEncoder.encode(puzzle)
    }
}
