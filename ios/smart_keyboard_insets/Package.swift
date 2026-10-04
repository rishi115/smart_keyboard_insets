// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "smart_keyboard_insets",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "smart-keyboard-insets", targets: ["smart_keyboard_insets"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "smart_keyboard_insets",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
