# ``PuzzleKit/PKGridCoordinate``

## Overview

Grids are typically ordered from the top left, starting at `(1, 1)`. This structure contains several useful utilities
for working with grids at a coordinate level.

## Topics

### Constants

- ``one``
- ``up``
- ``left``
- ``right``
- ``down``

### Neighbors

- ``above()``
- ``after(clampingTo:)``
- ``before()``
- ``below(clampingTo:)``

### Neighbors (Nullable)

- ``aboveOrNil()``
- ``after(stoppingAt:)``
- ``beforeOrNil()``
- ``below(stoppingAt:)``

### Conversion to Indices

Some puzzle structures might represent their grid as an array of tiles, rather than a two-dimensional array. These
methods are provided to simplify converting coordinates to array indices.

- ``toIndex(wrappingAround:in:)``
- ``toIndex(relativeTo:)``

### Scaling and Rotation

- ``rotated()``
