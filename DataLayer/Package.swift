// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLayer",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "DataLayer",
            targets: ["DataLayer"]),
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: .init("8.4.0")
        ),
        .package(url: "../Utilities", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DataLayer",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase"),
            ]),
        .testTarget(
            name: "DataLayerTests",
            dependencies: ["DataLayer"]),
    ]
)
