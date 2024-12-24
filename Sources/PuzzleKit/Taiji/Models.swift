//
//  Models.swift
//  PuzzleKit
//
//  Created by Marquis Kurt on 21-12-2024.
//

import Foundation

/// A representation of a Taiji puzzle tile.
public struct PKTaijiTile: Sendable, Equatable, Hashable, CustomStringConvertible {
    /// Whether this tile is currently filled in.
    public var filled: Bool = false

    /// The tile's current state.
    public var state: PKTaijiTileState

    /// The symbol the tile is marked with.
    public var symbol: PKTaijiTileSymbol?

    /// The symbol's color.
    public var color: PKTaijiSymbolColor? = .black

    public init(state: PKTaijiTileState, symbol: PKTaijiTileSymbol? = nil, color: PKTaijiSymbolColor? = nil) {
        self.state = state
        self.symbol = symbol
        self.color = color
        self.filled = false
    }

    public var description: String {
        let prefix = switch self.symbol {
        case .flower(let petals):
            "Flower(\(petals), "
        case .dot(let value, let additive):
            "Dot(\(additive ? "+" : "-")\(value), "
        case .diamond:
            "Diamond("
        case .slashdash(let rotates):
            "Slashdash(\(rotates), "
        case nil:
            "Tile("
        }
        return "\(prefix)state: \(self.state), filled: \(self.filled))"
    }

    /// Creates a normal, empty tile.
    public static func empty() -> Self {
        return .init(state: .normal)
    }

    /// Creates an invisible/"disabled" tile.
    ///
    /// Invisible tiles are typically used for non-rectangular layouts.
    public static func invisible() -> Self {
        return .init(state: .invisible)
    }

    /// Creates a normal tile with a symbol on it.
    /// - Parameter symbol: The symbol to place on the tile.
    /// - Parameter color: The tile symbol's color. Defaults to black.
    public static func symbolic(_ symbol: PKTaijiTileSymbol, coloredBy color: PKTaijiSymbolColor = .black) -> Self {
        return .init(state: .normal, symbol: symbol, color: color)
    }

    func applying(attributes: PKTaijiExtendedAttributes) -> PKTaijiTile {
        var tile = PKTaijiTile(state: attributes.state, symbol: self.symbol, color: attributes.color)
        tile.filled = attributes.filled
        return tile
    }
}

/// An enumeration of the states a Taiji tile can be in.
public enum PKTaijiTileState: Sendable, Equatable, Hashable {
    /// The tile can be interacted with.
    case normal

    /// The tile is locked in place and cannot be interacted with.
    case fixed

    /// The tile is completely invisible.
    ///
    /// This state is typically reserved for generated puzzles with non-rectangular shapes.
    case invisible
}

/// An enumeration of the symbols a Taiji tile can have.
public enum PKTaijiTileSymbol: Sendable, Equatable, Hashable {
    /// A flower with a set amount of filled-in petals.
    case flower(petals: Int)

    /// A dice dot with a given value, and whether it is additive.
    case dot(value: Int, additive: Bool)

    /// A diamond.
    case diamond

    /// A dash or slash, and whether it rotates.
    case slashdash(rotates: Bool)
}

/// An option set representing the mechanics available in the puzzle.
public struct PKTaijiMechanics: OptionSet, Sendable {
    /// The option set's raw value.
    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// The puzzle contains flower mechanics.
    public static let flower = PKTaijiMechanics(rawValue: 1)

    /// The puzzle contains slash/dash mechanics.
    public static let slashdash = PKTaijiMechanics(rawValue: 2)

    /// The puzzle contains diamond mechanics.
    public static let diamond = PKTaijiMechanics(rawValue: 4)

    /// The puzzle contains dot mechanics.
    public static let dot = PKTaijiMechanics(rawValue: 8)

    /// A shorthand form for all available mechanics.
    public static let all: PKTaijiMechanics = [.flower, .slashdash, .diamond, .dot]
}

public enum PKTaijiSymbolColor: Sendable, Equatable {
    case red, orange, yellow, green, blue, purple, white, black
}

struct PKTaijiExtendedAttributes: Sendable, Equatable {
    var color: PKTaijiSymbolColor = .black
    var filled: Bool
    var state: PKTaijiTileState
}

/// An enumeration of the errors that the decoder might throw.
public enum PKTaijiPuzzleDecoderError: Sendable, Error, Equatable {
    /// The width specified is an invalid value.
    case invalidBoardWidth
    /// The prefill width specified is an invalid value.
    case invalidPrefillWidth
    case invalidConstantIndex(index: Int?, constant: String)
    /// An unknown error occurred.
    case unknown(String)
}
