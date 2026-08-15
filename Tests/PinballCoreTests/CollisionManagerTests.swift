import CoreGraphics
import XCTest
@testable import PinballCore

final class CollisionManagerTests: XCTestCase {
    func testClampAndReflectBallFromLeftWall() {
        let config = PhysicsConfig.default
        let bounds = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let state = BallState(position: CGPoint(x: 6, y: 400), velocity: CGVector(dx: -300, dy: 0))

        let result = CollisionManager.resolve(
            ball: state,
            within: bounds,
            obstacleRects: [],
            config: config,
            deltaTime: 1.0 / 60.0
        )

        XCTAssertGreaterThan(result.velocity.dx, 0)
        XCTAssertGreaterThanOrEqual(result.position.x, config.ballRadius)
    }
}
