// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A representation of a grid coordinate.
public struct PKGridCoordinate: Hashable, Equatable, Sendable {
    /// The coordinate's position on the X/horizontal axis.
    public var x: Int

    /// The coordinate's position on the Y/vertical axis.
    public var y: Int

    /// Creates a coordinate in a grid.
    /// - Parameter x: The coordinate on the X axis.
    /// - Parameter y: The coordinate on the Y axis.
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    /// A coordinate representing (1, 1).
    public static let one = PKGridCoordinate(x: 1, y: 1)

    /// A coordinate representing the upward direction.
    ///
    /// To get the coordinate above another, use ``above()``.
    public static let up = PKGridCoordinate(x: 0, y: -1)

    /// A coordinate representing the leftward direction.
    ///
    /// To get the coordinate before another, use ``before()``.
    public static let left = PKGridCoordinate(x: -1, y: 0)

    /// A coordinate representing the rightward direction.
    ///
    /// To get the coordinate after another, use ``after(clampingTo:)``.
    public static let right = PKGridCoordinate(x: 1, y: 0)

    /// A coordinate representing the downward direction.
    ///
    /// To get the coordinate below another, use ``below(clampingTo:)``.
    public static let down = PKGridCoordinate(x: 0, y: 1)

    /// Returns a copy of the coordinate, rotated 90 degrees.
    public func rotated() -> Self {
        return .init(x: -self.y, y: self.x)
    }

    /// Converts the coordinate into an array index, relative to a grid's size and count.
    /// - Parameter width: The grid's width.
    /// - Parameter count: The number of tiles or squares in the grid.
    /// - Returns: An array index, or -1 if the coordinate is out of bounds relative to the grid's width and count.
    public func toIndex(wrappingAround width: Int, in count: Int) -> Int {
        let height = count / width
        if !(1...width).contains(self.x) || !(1...height).contains(self.y) { return -1 }
        return (width * (y - 1) + x) - 1
    }

    // - MARK: Neighbor Coordinates (Non-nullable/Coalescing)
    
    /// Retrieves the coordinate above.
    public func above() -> Self {
        return .init(x: self.x, y: max(1, self.y - 1))
    }

    /// Returns the coordinate before.
    public func before() -> Self {
        return .init(x: max(1, self.x - 1), y: self.y)
    }

    /// Returns the coordinate below.
    /// - Parameter maximum: The maximum coordinate on the Y axis.
    public func below(clampingTo maximum: Int? = nil) -> Self {
        if let maximum {
            return .init(x: self.x, y: min(maximum, self.y + 1))
        }
        return .init(x: self.x, y: self.y + 1)
    }

    /// Returns the coordinate after.
    /// - Parameter maximum: The maximum coordinate on the X axis.
    public func after(clampingTo maximum: Int? = nil) -> Self {
        if let maximum {
            return .init(x: min(maximum, self.x + 1), y: self.y)
        }
        return .init(x: self.x + 1, y: self.y)
    }

    // MARK: - Neighbor Coordinates (Nullable)

    /// Returns the coordinate above, or nil if the expected coordinate goes out of bounds.
    public func aboveOrNil() -> Self? {
        guard self.y - 1 > 0 else { return nil }
        return .init(x: self.x, y: max(1, self.y - 1))
    }

    /// Returns the coordinate before, or nil if the expected coordinate goes out of bounds.
    public func beforeOrNil() -> Self? {
        guard self.x - 1 > 0 else { return nil }
        return .init(x: max(1, self.x - 1), y: self.y)
    }


    /// Returns the coordinate below, or nil if the expected coordinate reaches out of bounds.
    /// - Parameter maximum: The maximum coordinate on the Y axis.
    public func below(stoppingAt maximum: Int? = nil) -> Self? {
        if let maximum, self.y + 1 > maximum { return nil }
        return .init(x: self.x, y: self.y + 1)
    }

    /// Returns the coordinate after, or nil if the expected coordinate reaches out of bounds.
    /// - Parameter maximum: The maximum coordinate on the X axis.
    public func after(stoppingAt maximum: Int? = nil) -> Self? {
        if let maximum, self.x + 1 > maximum { return nil }
        return .init(x: self.x + 1, y: self.y)
    }
}

extension PKGridCoordinate: CustomStringConvertible {
    public var description: String {
        return "Coord(\(x), \(y))"
    }
}

// MARK: - Operators

public extension PKGridCoordinate {
    /// Sums two grid coordinates together.
    static func + (lhs: PKGridCoordinate, rhs: PKGridCoordinate) -> PKGridCoordinate {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Sums a grid coordinate with a scalar integer value.
    static func + (lhs: PKGridCoordinate, rhs: Int) -> PKGridCoordinate {
        .init(x: lhs.x + rhs, y: lhs.y + rhs)
    }

    /// Subtracts two grid coordinates.
    static func - (lhs: PKGridCoordinate, rhs: PKGridCoordinate) -> PKGridCoordinate {
        .init(x: rhs.x - lhs.x, y: rhs.y - lhs.y)
    }

    /// Subtracts a scalar integer value from a grid coordinate.
    static func - (lhs:PKGridCoordinate, rhs: Int) -> PKGridCoordinate {
        .init(x: rhs - lhs.x, y: rhs - lhs.y)
    }
}
