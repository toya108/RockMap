// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]
        )
    ],
    dependencies: [
        .package(url: "../DataLayer", from: "1.0.0"),
        .package(url: "../FirebaseTestHelper", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "DataLayer", package: "DataLayer"),
                "FirebaseTestHelper"
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]
        )
    ]
)
