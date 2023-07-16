// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Domain",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Domain",
            targets: ["Domain"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Resolver", from: "1.0.0"),
        .package(path: "../DataLayer"),
        .package(path: "../FirebaseTestHelper")
    ],
    targets: [
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Resolver", package: "Resolver"),
                "DataLayer",
                "FirebaseTestHelper"
            ]
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]
        )
    ]
)
