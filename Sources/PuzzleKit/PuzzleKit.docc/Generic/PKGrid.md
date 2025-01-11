# ``PuzzleKit/PKGrid``

The structure of a grid is designed to be flexible, allowing for a variety of ways of representing tiles. For example,
``PKTaijiPuzzle`` stores its tiles in a single array, while other grid types might store their information in a
two-dimensional matrix.

### Coordinate System

Grids will typically start with an origin of (1, 1) and flow from the top left corner. This coordinate system was 
chosen for the following reasons:

- Using grid coordinates starting at (1, 1) allows for a more seamless transition between the visual appearance of a
  grid and its underlying implementation.
- PKGrid was initially built to support Taiji puzzles, and the original Lua implementation started at (1, 1). This
  approach helped ensure parity with the Lua implementation.

> Tip: Some grid types will offer conveniences for converting between indices and coordinates.

## Topics

### Coordinate System

- ``PKGridCoordinate``

### Dimensions

- ``width``
- ``height``

### Fetching Tiles

These methods guarantee a mode of accessing tiles regardless of internal implementations.

- ``tile(at:)``
- ``tile(above:)``
- ``tile(after:)``
- ``tile(below:)``
- ``tile(before:)``

### Regions

Regions can found by running the flood-fill algorithm starting from an origin tile, provided that the grid supports
flood-filling.

- ``PKGridRegion``
- ``PKFloodFillable``
- ``findFloodFilledRegion(startingAt:)``

### Layout Management

Grids can optionally support manipulating its dimensions through the ``PKGridStretchable`` protocol.

- ``PKGridStretchable``
