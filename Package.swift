// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NANYEN",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "NANYENCore", targets: ["NANYENCore"]),
        .executable(name: "NANYENApp", targets: ["NANYENApp"]),
        .executable(name: "NANYENCoreChecks", targets: ["NANYENCoreChecks"])
    ],
    targets: [
        .target(name: "NANYENCore"),
        .executableTarget(
            name: "NANYENApp",
            dependencies: ["NANYENCore"],
            resources: [.process("Resources")]
        ),
        .executableTarget(name: "NANYENCoreChecks", dependencies: ["NANYENCore"])
    ]
)
