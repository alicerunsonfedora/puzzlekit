# Taiji

@Metadata {
    @TitleHeading("Puzzle")
    @PageImage(purpose: card, source: "puzzle-taiji", alt: "An example of a Taiji puzzle board")
}

A constraint satisfaction grid puzzle using various encoded symbols.

## Overview

Taiji puzzles consist of a grid of tiles containing special symbols. Each symbol corresponds to its own unique mechanic
as demonstrated in the the game [Taiji](https://taiji-game.com), created by Matthew VanDevander. These mechanics are
often taught by means of rule discovery.

![An example of a Taiji puzzle board](puzzle-taiji.png)

> Note: The implementation of Taiji puzzles in PuzzleKit closely resembles the
> [`libtaiji`](https://github.com/alicerunsonfedora/libtaiji) library for Lua.

## Code representation

Taiji puzzles are encoded using the standard format for custom puzzles, originating from Taiji Maker for Windows and
the web-based Taiji editor. You can see an example code below:

```
3:+DAw0+D
```

Puzzle codes are typically written in the following format:

```
<width>:(<array-tile>|(<tile><attributes>))+
```

- `width` represents the width of the board.
- `(<tile><attributes>)` represents an individual tile with a color and other attributes.
- `array-tile` represents a series of tiles to be filled in consecutively. It is a shorthand form of
  `(<tile><attributes>)` where the tile is either an empty or invisible tile.

| Character | Meaning                                                                          |
| --------- | -------------------------------------------------------------------------------- |
| A-I       | Additive dots, where its value is determined by its position in the alphabet.    |
| J-R       | Subtractive dots, where its value is determined by its position in the alphabet. |
| S         | Diamond.                                                                         |
| T-U       | Dashes and slashes. U represents a rotating dash (slash).                        |
| V-Z       | Flowers, where its value is determined by its relative position in the alphabet. |

### Attributes

Following a tile with a symbol, a color and/or a state attribute might be defined. The tables below demonstrate the
various attributes for a tile.

@Row {
    @Column {
        | Color Code | Meaning                        |
        | ---------- | ------------------------------ |
        | r          | Red color                      |
        | o          | Orange color                   |
        | y          | Yellow color                   |
        | g          | Green color                    |
        | b          | Blue color                     |
        | p          | Purple color                   |
        | w          | Black color                    |
        | k          | White color                    |
    }
    @Column {
        | Attribute | Meaning                        |
        | --------- | ------------------------------ |
        | 0         | An unfilled normal tile.       |
        | 2         | A filled normal tile.          |
        | 4         | An unfilled locked/fixed tile. |
        | 6         | A filled locked/fixed tile.    |
        | 8         | An invisible tile.             |

        > Note: These attributes might be displayed on their own to mean a single tile of these state attributes.
    }
}

## Topics

- ``PKTaijiPuzzle``

### Validation

- ``PKTaijiPuzzleValidator``
- ``PKTaijiPuzzleValidatorError``
