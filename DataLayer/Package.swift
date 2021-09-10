// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLayer",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "DataLayer",
            targets: ["DataLayer"]
        )
    ],
    dependencies: [
        .package(
            name: "Firebase",
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            from: .init("8.6.0")
        ),
        .package(url: "../Utilities", from: "1.0.0"),
        .package(url: "../FirebaseTestHelper", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "DataLayer",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseFirestoreSwift-Beta", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase"),
                "Utilities",
                "FirebaseTestHelper"
            ]
        ),
        .testTarget(
            name: "DataLayerTests",
            dependencies: [
                "DataLayer"
            ]
        )
    ]
)
