// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-audio-hardware",
    platforms: [.macOS(.v12),],
    products: [
        .library(
            name: "SPFKAudioHardware",
            targets: ["SPFKAudioHardware", "SPFKAudioHardwareC",]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-base", from: "0.0.3"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "SPFKAudioHardware",
            dependencies: [
                .targetItem(name: "SPFKAudioHardwareC", condition: nil),
                .product(name: "SPFKBase", package: "spfk-base"),
            ]
        ),
        .target(
            name: "SPFKAudioHardwareC",
            dependencies: [],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include_private")
            ],
            cxxSettings: [
                .headerSearchPath("include_private")
            ]
        ),
        .testTarget(
            name: "SPFKAudioHardwareTests",
            dependencies: [
                .targetItem(name: "SPFKAudioHardware", condition: nil),
                .targetItem(name: "SPFKAudioHardwareC", condition: nil),
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
