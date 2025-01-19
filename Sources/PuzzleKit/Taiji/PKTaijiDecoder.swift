//
//  PKTaijiDecoder.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 22-12-2024.
//

enum PKTaijiDecoder {
    typealias DecodeError = PKTaijiPuzzleDecoderError
    struct Constants: Sendable {
        static let digits: String = "1234567890"
        static let upperAlphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        static let lowerAlphabet: String = "abcdefghijklmnopqrstuvwxyz"

        static let fillEmpty: Character = "+"
        static let fillFixed: Character = "-"

        static let dots: String = "ABCDEFGHIJKLMNOPQR"
        static let dotsPositive: String = "ABCDEFGHI"
        static let dotsNegative: String = "JKLMNOPQR"
        static let diamond: Character = "S"
        static let dash: Character = "T"
        static let slash: Character = "U"
        static let flowers: String = "VWXYZ"
        static let specialDigits = "02468"
        static let colors = "roygbpwk"

        static let colorMap: [Character: PKTaijiSymbolColor] = [
            "r": .red, "o": .orange, "y": .yellow, "g": .green, "b": .blue, "p": .purple, "w": .black, "k": .white
        ]
    }

    enum State: Sendable, Equatable {
        case initial
        case getWidth
        case scanForTile
        case prefillArray(invisible: Bool)
        case readExtendedAttributes
        case error(PKTaijiPuzzleDecoderError)
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity large_tuple
    static func decode(from source: String) throws(DecodeError) -> (Int, [PKTaijiTile], PKTaijiMechanics) {
        var sourceToParse = source
        var tiles = [PKTaijiTile]()
        var mechanics: PKTaijiMechanics = []
        var boardWidth = 0
        var state = State.initial
        var widthString = ""
        var extendedAttrsChars = 0

        while sourceToParse.contains(Constants.fillEmpty) {
            sourceToParse = try decompress(sourceToParse, character: Constants.fillEmpty)
        }

        while sourceToParse.contains(Constants.fillFixed) {
            sourceToParse = try decompress(sourceToParse, character: Constants.fillFixed)
        }

        for (charIndex, character) in sourceToParse.enumerated() {
            switch (character, state) {
            case let (char, .initial) where Constants.digits.contains(char),
                let (char, .getWidth) where Constants.digits.contains(char):
                if state == .initial { state = .getWidth }
                widthString += String(char)
            case (":", .getWidth):
                guard let convertedNumber = Int(widthString) else {
                    throw .invalidBoardWidth
                }
                boardWidth = convertedNumber
                state = .scanForTile
            case let (char, .scanForTile) where Constants.dots.contains(char):
                guard let index = Constants.dots.firstIndex(of: char) else {
                    throw .invalidConstantIndex(index: nil, constant: Constants.dots)
                }
                var value = Constants.dots.distance(to: index) + 1
                let additive = value <= 9
                if value > 9 {
                    value = abs(9 - value)
                }
                var tile = PKTaijiTile.symbolic(.dot(value: value, additive: additive))
                if let (extendedAttrs, readChars) = Self.getAttributes(after: charIndex, in: sourceToParse) {
                    tile = tile.applying(attributes: extendedAttrs)
                    state = .readExtendedAttributes
                    extendedAttrsChars = readChars
                }
                tiles.append(tile)
                mechanics.insert(.dot)
            case let (char, .scanForTile) where Constants.flowers.contains(char):
                guard let index = Constants.flowers.firstIndex(of: char) else {
                    throw .invalidConstantIndex(index: nil, constant: Constants.dots)
                }
                let value = Constants.flowers.distance(to: index)
                var tile = PKTaijiTile.symbolic(.flower(petals: value))
                if let (extendedAttrs, readChars) = Self.getAttributes(after: charIndex, in: sourceToParse) {
                    tile = tile.applying(attributes: extendedAttrs)
                    state = .readExtendedAttributes
                    extendedAttrsChars = readChars
                }
                tiles.append(tile)
                mechanics.insert(.flower)
            case (Constants.diamond, .scanForTile):
                var tile = PKTaijiTile.symbolic(.diamond)
                if let (extendedAttrs, readChars) = Self.getAttributes(after: charIndex, in: sourceToParse) {
                    tile = tile.applying(attributes: extendedAttrs)
                    state = .readExtendedAttributes
                    extendedAttrsChars = readChars
                }
                tiles.append(tile)
                mechanics.insert(.diamond)
            case (Constants.dash, .scanForTile), (Constants.slash, .scanForTile):
                var tile = PKTaijiTile.symbolic(.slashdash(rotates: character == Constants.slash))
                if let (extendedAttrs, readChars) = Self.getAttributes(after: charIndex, in: sourceToParse) {
                    tile = tile.applying(attributes: extendedAttrs)
                    state = .readExtendedAttributes
                    extendedAttrsChars = readChars
                }
                tiles.append(tile)
                mechanics.insert(.slashdash)
            case let (char, .readExtendedAttributes):
                extendedAttrsChars -= 1
                if extendedAttrsChars == 0 {
                    state = .scanForTile
                    continue
                }
                let extendedAttrs = Constants.specialDigits + Constants.colors
                if !extendedAttrs.contains(char) {
                    state = .scanForTile
                    extendedAttrsChars = 0
                }
            case let (char, .scanForTile) where Constants.specialDigits.contains(char):
                let (filled, state) = Self.parseSpecialDigit(char)
                var tile = PKTaijiTile(state: state)
                tile.filled = filled
                tiles.append(tile)
            default:
                break
            }
        }

        return (boardWidth, tiles, mechanics)
    }

    private static func decompress(_ sourceToParse: String, character: Character) throws(DecodeError) -> String {
        guard let plusIdx = sourceToParse.firstIndex(of: character) else { return sourceToParse }
        var newSource = sourceToParse
        let char = newSource[newSource.index(after: plusIdx)]
        newSource.remove(at: newSource.index(after: plusIdx))
        guard let charCode = char.asciiValue else { return sourceToParse }
        let count = Int(charCode) - 64
        guard (1...26).contains(count) else {
            throw .invalidPrefillWidth
        }
        newSource.insert(
            contentsOf: String(repeating: "0", count: count),
            at: newSource.index(after: plusIdx))
        newSource.remove(at: plusIdx)
        return newSource
    }

    private static func parseSpecialDigit(_ digit: Character) -> (Bool, PKTaijiTileState) {
        return switch digit {
        case "0", "2":
            (digit == "2", .normal)
        case "4", "6":
            (digit == "6", .fixed)
        default:
            (false, .invisible)
        }
    }

    private static func getAttributes(after index: Int, in source: String) -> (PKTaijiExtendedAttributes, Int)? {
        var color: PKTaijiSymbolColor?
        var readChars = 0
        var (filled, state) = (false, PKTaijiTileState.normal)
        let strIndex = source.index(source.startIndex, offsetBy: index + 1)
        let colorCharacter = source[strIndex]

        if Constants.colors.contains(colorCharacter) {
            color = Constants.colorMap[colorCharacter] ?? .black
            readChars += 1

            let attribCharacter = source[source.index(after: strIndex)]
            if Constants.specialDigits.contains(attribCharacter) {
                readChars += 1
                (filled, state) = Self.parseSpecialDigit(attribCharacter)
            } else {
                filled = false
                state = .normal
            }
        } else {
            guard Constants.specialDigits.contains(colorCharacter) else { return nil }
            readChars += 1
            (filled, state) = Self.parseSpecialDigit(colorCharacter)
        }

        return (.init(color: color ?? .black, filled: filled, state: state), readChars)
    }
}
