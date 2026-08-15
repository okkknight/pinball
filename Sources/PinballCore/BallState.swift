import CoreGraphics

public enum CollisionKind: Equatable, Sendable {
    case none
    case screenEdge
    case windowBounds
}

public struct BallState: Equatable, Sendable {
    public var position: CGPoint
    public var velocity: CGVector
    public var isLaunched: Bool
    public var collisionKind: CollisionKind

    public init(
        position: CGPoint,
        velocity: CGVector,
        isLaunched: Bool = false,
        collisionKind: CollisionKind = .none
    ) {
        self.position = position
        self.velocity = velocity
        self.isLaunched = isLaunched
        self.collisionKind = collisionKind
    }
}

public struct CollisionResult: Sendable {
    public var state: BallState
    public var collisionPoints: [CGPoint]

    public init(state: BallState, collisionPoints: [CGPoint]) {
        self.state = state
        self.collisionPoints = collisionPoints
    }

    public var position: CGPoint {
        state.position
    }

    public var velocity: CGVector {
        state.velocity
    }

    public var collisionKind: CollisionKind {
        state.collisionKind
    }
}
