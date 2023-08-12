// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLayer",
    platforms: [
        .iOS(.v15),
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
            from: .init("8.6.0")!
        ),
        .package(url: "https://github.com/hmlongco/Resolver", from: .init("1.0.0")!),
        .package(path: "../Utilities")
    ],
    targets: [
        .target(
            name: "DataLayer",
            dependencies: [
                .product(name: "FirebaseFirestore", package: "Firebase"),
                .product(name: "FirebaseFirestoreSwift-Beta", package: "Firebase"),
                .product(name: "FirebaseStorage", package: "Firebase"),
                .product(name: "Resolver", package: "Resolver"),
                "Utilities"
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
