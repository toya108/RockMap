// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FirebaseTestHelper",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "FirebaseTestHelper",
            targets: ["FirebaseTestHelper"])
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: .init("8.6.0")
        )
    ],
    targets: [
        .target(
            name: "FirebaseTestHelper",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "Firebase")
            ]),
        .testTarget(
            name: "FirebaseTestHelperTests",
            dependencies: ["FirebaseTestHelper"])
    ]
)
