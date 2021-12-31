// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RockMapTools",
    platforms: [
        .iOS(.v15)
    ],
    dependencies: [
        .package(
            url: "https://github.com/mono0926/LicensePlist",
            from: .init("3.0.7")
        ),
        .package(
            url: "https://github.com/realm/SwiftLint",
            from: .init("0.45.1")
        )
    ],
    targets: [
        .target(name: "RockMapTools", path: "")
    ]
)
