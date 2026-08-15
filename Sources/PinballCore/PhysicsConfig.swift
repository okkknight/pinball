import CoreGraphics

public struct PhysicsConfig: Sendable {
    public var ballRadius: CGFloat
    public var bounceCoefficient: CGFloat
    public var linearDampingPerSecond: CGFloat
    public var maxSpeed: CGFloat
    public var minimumSpeed: CGFloat
    public var launchSpeedMultiplier: CGFloat
    public var trailLength: Int

    public static let `default` = PhysicsConfig(
        ballRadius: 14,
        bounceCoefficient: 0.94,
        linearDampingPerSecond: 0.03,
        maxSpeed: 2600,
        minimumSpeed: 14,
        launchSpeedMultiplier: 12,
        trailLength: 28
    )

    public init(
        ballRadius: CGFloat,
        bounceCoefficient: CGFloat,
        linearDampingPerSecond: CGFloat,
        maxSpeed: CGFloat,
        minimumSpeed: CGFloat,
        launchSpeedMultiplier: CGFloat,
        trailLength: Int
    ) {
        self.ballRadius = ballRadius
        self.bounceCoefficient = bounceCoefficient
        self.linearDampingPerSecond = linearDampingPerSecond
        self.maxSpeed = maxSpeed
        self.minimumSpeed = minimumSpeed
        self.launchSpeedMultiplier = launchSpeedMultiplier
        self.trailLength = trailLength
    }
}
