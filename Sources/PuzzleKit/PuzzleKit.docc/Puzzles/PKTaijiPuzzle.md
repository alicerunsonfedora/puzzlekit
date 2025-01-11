# ``PuzzleKit/PKTaijiPuzzle``

@Metadata {
    @TitleHeading("Puzzle")
    @PageImage(purpose: card, source: "puzzle-taiji")
}

## Overview

This structure is used to create, edit, and check Taiji puzzles. 

> Note: For more information on how Taiji puzzles operate, refer to <doc:Taiji>.


Creating a puzzle can be accomplished by initializing with a size:

```swift
import PuzzleKit

let puzzle = PKTaijiPuzzle(size: .init(width: 3, height: 3))
```

For a puzzle with a more complex code, use the ``init(decoding:)`` initializer:

```swift
import PuzzleKit

let puzzle = try PKTaijiPuzzle(decoding: "1:Tw0")
```

### Codable support

Codable support is also offered for cases where puzzles are contained in Codable structs, or for multiwindow support in
SwiftUI.

For example, you might have a file structure that looks like the following:

```swift
struct MyPuzzleFile: Codable {
    var name: String
    var author: String
    var puzzle: PKTaijiPuzzle
}
```

When the puzzle is encoded as a string, the puzzle will automatically be constructed, as if ``init(decoding:)`` were
called:

```swift
let json =
    """
    {
        "name": "Geschlossene Erinnerungen",
        "author": "Lorelei Weiss",
        "puzzle": "6:644+B26Tw640Uw22644+B2"
    }
    """

let data = json.data(using: .utf8)!
let decoder = JSONDecoder()
let result = try decoder.decode(MyPuzzleFile.self, from: data)
```

When encoding data, the puzzle will be encoded into a string code, as if ``Swift/String/init(encoding:)`` were called:

```swift
let pzl = MyPuzzleFile(...)
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let json = try encoder.encode(pzl)
```

## Editing Tiles

Tiles cannot be edited directly. Instead, several methods are available to allow manipulation of tiles. These methods
will produce a new puzzle rather than modifying the existing one, allowing for better version control. See below for
the various types of manipulations.

@TabNavigator {
    @Tab("Flipping Tiles") {
        @Row {
            @Column {
                Tiles can be flipped on or off based on their current state. Use ``flippingTile(at:)`` to flip the tile
                in question:
                
                ```swift
                let puzzle = PKTaijiPuzzle(...)
                
                let updatedPuzzle = puzzle.flippingTile(at: .one)
                ```
            }
            @Column {
                @Video(source: "pktaijipuzzle-flip", alt: "A demonstration of flipping a tile.")
            }
        }
    }
    @Tab("Changing Symbols") {
        Tiles can also contain symbols that require different constraints to be satisfied. Use 
        ``replacingSymbol(at:with:)`` to update the symbol on the specified tile:
        
        ```swift
        let puzzle = PKTaijiPuzzle(...)
        
        let updatedPuzzle = puzzle
            .replacingSymbol(at: .one, with: .diamond)
        ```
    }
    @Tab("Updating Tile States") {
        Tiles can be represented in one of three states: ``PKTaijiTileState/normal``, which allows for general user
        interaction, ``PKTaijiTileState/fixed``, which prevents user interaction, and ``PKTaijiTileState/invisible``,
        which prevents user interaction while also hiding the tile from view.
        
        Use the ``applyingState(at:with:)`` method to update an individual tile's state:
        
        ```swift
        let puzzle = PKTaijiPuzzle(...)
        
        let updatedPuzzle = puzzle
            .applyingState(at: .one, with: .fixed)
        ```
    }
}

These methods can also be chained together to perform multiple operations:

```swift
let updatedPuzzle = puzzle
    .applyingState(at: .init(x: 2, y: 2), with: .fixed)
    .replacingSymbol(at: .init(x: 2, y: 2),
                     with: .slashdash(rotates: false))
```

## Validation

To validate that the current puzzle board contains a correct solution, call on the ``validate()`` method. The 
validation will return either a success value, or a failure with the first error on the board in question.

```swift
let validationResult = puzzle.validate()

switch validationResult {
case .success(_):
    print("The puzzle is correct!")
case .failure(let error):
    print(error)
}
```

Alternatively, you can initialize your own ``PKTaijiPuzzleValidator`` and run the validation from it:

```swift
let validator = PKTaijiPuzzleValidator(puzzle: puzzle)
let validationResult = validator.validate()
```

The ``PKTaijiPuzzleValidator`` will allow you to control how the validation is handled, and what to account for when
validating the puzzle.

## Topics

### Encoding and Decoding

- ``init(decoding:)``
- ``init(from:)``
- ``encode(to:)``
- ``Swift/String/init(encoding:)``
- ``PKTaijiPuzzleDecoderError``

### Mechanics

- ``mechanics``
- ``PKTaijiMechanics``

### Grid Tiles

- ``tiles``
- ``PKTaijiTile``
- ``PKTaijiTileState``
- ``PKTaijiTileSymbol``
- ``PKTaijiSymbolColor``

### Manipulating Tiles

While tiles cannot be directly modified, these methods allow you to update tiles at a specific coordinate.

- ``applyingState(at:with:)``
- ``flippingTile(at:)``
- ``replacingSymbol(at:with:)``

### Validation

- ``validate()``


