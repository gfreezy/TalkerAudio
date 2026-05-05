// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TalkerAudio",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TalkerAudio",
            targets: ["TalkerAudio"])
    ],
    dependencies: [
        .package(url: "https://github.com/gfreezy/talkercommon", from: "20260505.0.1"),
        .package(url: "https://github.com/gfreezy/StreamAudioPlayer", from: "20260503.0.2"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/groue/Semaphore", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-testing", from: "0.1.0"),
        .package(url: "https://github.com/vector-im/opus-swift", from: "0.8.4"),
        .package(url: "https://github.com/vector-im/ogg-swift", from: "0.8.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TalkerAudioObjC",
            dependencies: ["MicrosoftCognitiveServicesSpeech"]
        ),
        .binaryTarget(
            name: "MicrosoftCognitiveServicesSpeech",
            path: "Frameworks/MicrosoftCognitiveServicesSpeech.xcframework"
        ),
        .target(
            name: "TalkerAudio",
            dependencies: [
                "TalkerAudioObjC",
                .product(name: "TalkerCommonLogging", package: "talkercommon"),
                .product(name: "TalkerCommonError", package: "talkercommon"),
                .product(name: "StreamAudio", package: "StreamAudioPlayer"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "Semaphore", package: "Semaphore"),
                .target(name: "MicrosoftCognitiveServicesSpeech"),
                .product(name: "YbridOpus", package: "opus-swift"),
                .product(name: "YbridOgg", package: "ogg-swift"),
            ]
        ),
        .testTarget(
            name: "TalkerAudioTests",
            dependencies: [
                "TalkerAudio",
                .product(name: "Testing", package: "swift-testing"),
            ]),
    ]
)
