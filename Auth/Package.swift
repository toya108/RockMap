// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Auth",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Auth",
            targets: ["Auth"]
        ),
    ],
    dependencies: [
        .package(
            name: "FirebaseUI",
            url: "https://github.com/firebase/FirebaseUI-iOS.git",
            from: .init("12.0.2")
        ),
        .package(url: "../Domain", from: "1.0.0"),
        .package(url: "../Utilities", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Auth",
            dependencies: [
                .product(name: "FirebaseAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseGoogleAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseEmailAuthUI", package: "FirebaseUI"),
                .product(name: "FirebaseOAuthUI", package: "FirebaseUI"),
                .product(name: "Domain", package: "Domain"),
            ]
        ),
        .testTarget(
            name: "AuthTests",
            dependencies: ["Auth"]
        ),
    ]
)
