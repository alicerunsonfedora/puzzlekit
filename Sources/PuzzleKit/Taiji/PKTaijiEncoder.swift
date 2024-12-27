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
        let rawString = puzzle.tiles.map { $0.encode() }.reduce("", +)

        let reducedString = rawString.replacing(/(00)+0*/) { output in
            let length = output.output.0.count
            return "+\(Constants.upperAlphabet.character(at: length - 1))"
        }.replacing(/(88)+8*/) { output in
            let length = output.output.0.count
            return "-\(Constants.upperAlphabet.character(at: length - 1))"
        }

        return prefix + reducedString
    }
}

public extension String {
    init(encoding puzzle: PKTaijiPuzzle) {
        self = PKTaijiEncoder.encode(puzzle)
    }
}
