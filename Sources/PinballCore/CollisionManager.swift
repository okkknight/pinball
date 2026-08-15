import CoreGraphics
import Foundation

public enum CollisionManager {
    public static func resolve(
        ball: BallState,
        within bounds: CGRect,
        obstacleRects: [CGRect],
        config: PhysicsConfig,
        deltaTime: CGFloat
    ) -> CollisionResult {
        guard deltaTime > 0 else {
            return CollisionResult(state: ball, collisionPoints: [])
        }

        var state = ball
        var collisionPoints: [CGPoint] = []

        state.velocity = state.velocity.clamped(maxLength: config.maxSpeed)
        let damping = pow(max(0, 1 - config.linearDampingPerSecond), deltaTime)
        state.velocity = state.velocity * damping

        let speed = max(state.velocity.length, config.minimumSpeed)
        let stepDistance = max(1, config.ballRadius * 0.5)
        let stepCount = max(1, min(12, Int(ceil((speed * deltaTime) / stepDistance))))
        let stepTime = deltaTime / CGFloat(stepCount)

        for _ in 0..<stepCount {
            state.position = state.position + state.velocity * stepTime
            let screenHitPoints = resolveAgainstScreenBounds(&state, bounds: bounds, config: config)
            collisionPoints.append(contentsOf: screenHitPoints)

            for obstacleRect in obstacleRects {
                let obstacleHitPoints = resolveAgainstObstacle(&state, obstacleRect: obstacleRect, config: config)
                collisionPoints.append(contentsOf: obstacleHitPoints)
            }
        }

        state.velocity = state.velocity.clamped(maxLength: config.maxSpeed)
        if state.velocity.length < config.minimumSpeed {
            state.velocity = CGVector(dx: 0, dy: 0)
        }

        state.collisionKind = collisionPoints.isEmpty ? .none : .windowBounds
        return CollisionResult(state: state, collisionPoints: collisionPoints)
    }

    private static func resolveAgainstScreenBounds(
        _ state: inout BallState,
        bounds: CGRect,
        config: PhysicsConfig
    ) -> [CGPoint] {
        var impacts: [CGPoint] = []
        let radius = config.ballRadius

        if state.position.x < bounds.minX + radius {
            state.position.x = bounds.minX + radius
            state.velocity.dx = abs(state.velocity.dx) * config.bounceCoefficient
            impacts.append(CGPoint(x: bounds.minX, y: state.position.y))
            state.collisionKind = .screenEdge
        } else if state.position.x > bounds.maxX - radius {
            state.position.x = bounds.maxX - radius
            state.velocity.dx = -abs(state.velocity.dx) * config.bounceCoefficient
            impacts.append(CGPoint(x: bounds.maxX, y: state.position.y))
            state.collisionKind = .screenEdge
        }

        if state.position.y < bounds.minY + radius {
            state.position.y = bounds.minY + radius
            state.velocity.dy = abs(state.velocity.dy) * config.bounceCoefficient
            impacts.append(CGPoint(x: state.position.x, y: bounds.minY))
            state.collisionKind = .screenEdge
        } else if state.position.y > bounds.maxY - radius {
            state.position.y = bounds.maxY - radius
            state.velocity.dy = -abs(state.velocity.dy) * config.bounceCoefficient
            impacts.append(CGPoint(x: state.position.x, y: bounds.maxY))
            state.collisionKind = .screenEdge
        }

        return impacts
    }

    private static func resolveAgainstObstacle(
        _ state: inout BallState,
        obstacleRect: CGRect,
        config: PhysicsConfig
    ) -> [CGPoint] {
        let inflated = obstacleRect.insetBy(dx: -config.ballRadius, dy: -config.ballRadius)
        guard inflated.contains(state.position) else {
            return []
        }

        let distances: [(side: Side, value: CGFloat)] = [
            (.left, abs(state.position.x - inflated.minX)),
            (.right, abs(inflated.maxX - state.position.x)),
            (.bottom, abs(state.position.y - inflated.minY)),
            (.top, abs(inflated.maxY - state.position.y))
        ]
        guard let minimum = distances.min(by: { $0.value < $1.value })?.value else {
            return []
        }

        var impacts: [CGPoint] = []
        if distances.contains(where: { $0.side == .left && $0.value == minimum }) {
            state.position.x = inflated.minX
            state.velocity.dx = -abs(state.velocity.dx) * config.bounceCoefficient
            impacts.append(CGPoint(x: obstacleRect.minX, y: state.position.y))
        }
        if distances.contains(where: { $0.side == .right && $0.value == minimum }) {
            state.position.x = inflated.maxX
            state.velocity.dx = abs(state.velocity.dx) * config.bounceCoefficient
            impacts.append(CGPoint(x: obstacleRect.maxX, y: state.position.y))
        }
        if distances.contains(where: { $0.side == .bottom && $0.value == minimum }) {
            state.position.y = inflated.minY
            state.velocity.dy = -abs(state.velocity.dy) * config.bounceCoefficient
            impacts.append(CGPoint(x: state.position.x, y: obstacleRect.minY))
        }
        if distances.contains(where: { $0.side == .top && $0.value == minimum }) {
            state.position.y = inflated.maxY
            state.velocity.dy = abs(state.velocity.dy) * config.bounceCoefficient
            impacts.append(CGPoint(x: state.position.x, y: obstacleRect.maxY))
        }

        if !impacts.isEmpty {
            state.collisionKind = .windowBounds
        }

        return impacts
    }
}

private enum Side {
    case left
    case right
    case top
    case bottom
}
