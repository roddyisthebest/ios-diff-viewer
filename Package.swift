// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-diff-viewer",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ios-diff-viewer",
            targets: ["ios-diff-viewer"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ios-diff-viewer"
        ),
        .testTarget(
            name: "ios-diff-viewerTests",
            dependencies: ["ios-diff-viewer"]
        ),
    ]
)
