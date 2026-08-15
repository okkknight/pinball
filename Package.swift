// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Pinball",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "PinballCore", targets: ["PinballCore"])
    ],
    targets: [
        .target(
            name: "PinballCore"
        ),
        .testTarget(
            name: "PinballCoreTests",
            dependencies: ["PinballCore"]
        )
    ]
)
