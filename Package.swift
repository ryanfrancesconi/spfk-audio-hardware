// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-audio-hardware",
    platforms: [.macOS(.v13),],
    products: [
        .library(
            name: "SPFKAudioHardware",
            targets: ["SPFKAudioHardware",]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-base", from: "0.0.3"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", from: "0.0.5"),
    ],
    targets: [
        .target(
            name: "SPFKAudioHardware",
            dependencies: [
                .product(name: "SPFKBase", package: "spfk-base"),
            ]
        ),
        .testTarget(
            name: "SPFKAudioHardwareTests",
            dependencies: [
                .targetItem(name: "SPFKAudioHardware", condition: nil),
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ]
)
