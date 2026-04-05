// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SafeDecoding",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SafeDecoding",
            targets: ["SafeDecoding"]
        )
    ],
    targets: [
        .target(
            name: "SafeDecoding"
        ),
        .testTarget(
            name: "SafeDecodingTests",
            dependencies: ["SafeDecoding"]
        )
    ]
)
