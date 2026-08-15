import AppKit
import CoreGraphics
import SpriteKit

@MainActor
final class PinballScene: SKScene {
    private let config: PhysicsConfig
    private var worldOrigin: CGPoint
    private var worldBounds: CGRect

    var obstacleRectsProvider: (() -> [CGRect])?

    private var obstacleRects: [CGRect] = []
    private var ballState: BallState
    private var lastUpdateTime: TimeInterval?
    private var simulationPaused = false

    private let ballNode = SKShapeNode(circleOfRadius: PhysicsConfig.default.ballRadius)
    private let trailNode = SKNode()
    private let impactNode = SKNode()
    private var trailPositions: [CGPoint] = []

    var isSimulationPaused: Bool {
        simulationPaused
    }

    init(size: CGSize, worldOrigin: CGPoint, config: PhysicsConfig) {
        self.config = config
        self.worldOrigin = worldOrigin
        self.worldBounds = CGRect(origin: worldOrigin, size: size)
        self.ballState = BallState(position: CGPoint(x: worldOrigin.x + config.ballRadius, y: worldOrigin.y + config.ballRadius), velocity: CGVector(dx: 0, dy: 0))
        super.init(size: size)

        scaleMode = .resizeFill
        backgroundColor = .clear
        anchorPoint = .zero
        isUserInteractionEnabled = false

        ballNode.fillColor = NSColor.systemPink
        ballNode.strokeColor = NSColor.white.withAlphaComponent(0.9)
        ballNode.lineWidth = 1.5
        ballNode.glowWidth = 6
        ballNode.isHidden = true

        addChild(trailNode)
        addChild(impactNode)
        addChild(ballNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(worldOrigin: CGPoint, worldBounds: CGRect) {
        self.worldOrigin = worldOrigin
        self.worldBounds = worldBounds
        self.size = worldBounds.size
        updateNodePositions()
    }

    func setObstacleRects(_ rects: [CGRect]) {
        obstacleRects = rects
    }

    func pauseSimulation(_ paused: Bool) {
        simulationPaused = paused
    }

    func resetBall(at globalPoint: CGPoint) {
        ballState = BallState(position: globalPoint, velocity: CGVector(dx: 0, dy: 0), isLaunched: false)
        lastUpdateTime = nil
        trailPositions.removeAll()
        updateNodePositions()
        ballNode.isHidden = true
        trailNode.removeAllChildren()
        impactNode.removeAllChildren()
    }

    func launchBall(from globalPoint: CGPoint, velocity: CGVector) {
        ballState = BallState(position: globalPoint, velocity: velocity, isLaunched: true)
        lastUpdateTime = nil
        ballNode.isHidden = false
        updateNodePositions()
    }

    override func update(_ currentTime: TimeInterval) {
        guard ballState.isLaunched, !simulationPaused else {
            lastUpdateTime = currentTime
            return
        }

        let deltaTime = CGFloat(lastUpdateTime.map { currentTime - $0 } ?? (1.0 / 60.0))
        lastUpdateTime = currentTime

        obstacleRects = obstacleRectsProvider?() ?? obstacleRects

        let result = CollisionManager.resolve(
            ball: ballState,
            within: worldBounds,
            obstacleRects: obstacleRects,
            config: config,
            deltaTime: deltaTime
        )

        ballState = result.state
        renderBall()
        renderTrail()
        renderCollisions(result.collisionPoints)
    }

    private func renderBall() {
        ballNode.isHidden = !ballState.isLaunched
        ballNode.position = scenePosition(fromGlobal: ballState.position)
    }

    private func renderTrail() {
        guard ballState.isLaunched else { return }

        trailPositions.append(ballState.position)
        if trailPositions.count > config.trailLength {
            trailPositions.removeFirst(trailPositions.count - config.trailLength)
        }

        trailNode.removeAllChildren()
        for (index, point) in trailPositions.enumerated() {
            let alpha = CGFloat(index + 1) / CGFloat(trailPositions.count)
            let trailDot = SKShapeNode(circleOfRadius: config.ballRadius * 0.35)
            trailDot.position = scenePosition(fromGlobal: point)
            trailDot.fillColor = NSColor.white.withAlphaComponent(alpha * 0.25)
            trailDot.strokeColor = NSColor.clear
            trailDot.alpha = alpha * 0.7
            trailNode.addChild(trailDot)
        }
    }

    private func renderCollisions(_ collisionPoints: [CGPoint]) {
        guard !collisionPoints.isEmpty else { return }

        for point in collisionPoints {
            let ring = SKShapeNode(circleOfRadius: config.ballRadius * 1.25)
            ring.position = scenePosition(fromGlobal: point)
            ring.fillColor = NSColor.clear
            ring.strokeColor = NSColor.white.withAlphaComponent(0.85)
            ring.lineWidth = 2
            ring.alpha = 0.9
            ring.setScale(0.6)
            let expand = SKAction.group([
                SKAction.scale(to: 1.9, duration: 0.22),
                SKAction.fadeOut(withDuration: 0.22)
            ])
            ring.run(SKAction.sequence([expand, SKAction.removeFromParent()]))
            impactNode.addChild(ring)
        }
    }

    private func updateNodePositions() {
        ballNode.position = scenePosition(fromGlobal: ballState.position)
    }

    private func scenePosition(fromGlobal point: CGPoint) -> CGPoint {
        CGPoint(x: point.x - worldOrigin.x, y: point.y - worldOrigin.y)
    }
}
