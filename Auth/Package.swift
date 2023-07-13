// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Auth",
            targets: ["Auth"]
        )
    ],
    dependencies: [
        .package(
            name: "FirebaseUI",
            url: "https://github.com/firebase/FirebaseUI-iOS.git",
            from: .init("12.2.0")!
        ),
        .package(url: "https://github.com/hmlongco/Resolver", from: .init("1.0.0")!),
        .package(path: "../Domain"),
        .package(path: "../Utilities")
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "FirebaseAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseGoogleAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseEmailAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseOAuthUI", package: "FirebaseUI"),
                .product(name: "Resolver", package: "Resolver"),
                "Domain"
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: ["Auth"]
        )
    ]
)
