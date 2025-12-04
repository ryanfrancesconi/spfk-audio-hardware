// swift-tools-version: 6.2
// Copyright Ryan Francesconi. All Rights Reserved. Revision History at https://github.com/ryanfrancesconi

import PackageDescription

let package = Package(
    name: "spfk-audio-hardware",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "SPFKAudioHardware",
            targets: [
                "SPFKAudioHardware",
                "SPFKAudioHardwareC",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ryanfrancesconi/spfk-base", branch: "development"),
        .package(url: "https://github.com/ryanfrancesconi/spfk-testing", branch: "development"),

    ],
    targets: [
        .target(
            name: "SPFKAudioHardware",
            dependencies: [
                "SPFKAudioHardwareC",
                .product(name: "SPFKBase", package: "spfk-base"),
            ]
        ),

        .target(
            name: "SPFKAudioHardwareC",
            dependencies: [
            ],
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
                "SPFKAudioHardware",
                "SPFKAudioHardwareC",
                .product(name: "SPFKTesting", package: "spfk-testing"),
            ]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
