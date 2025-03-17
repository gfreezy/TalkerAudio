// swift-tools-version: 6.0
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
        .package(url: "https://github.com/gfreezy/talkercommon", from: "20241210.1.8"),
        .package(url: "https://github.com/gfreezy/StreamAudioPlayer", from: "20241212.0.3"),
        .package(url: "https://github.com/SwiftyLab/AsyncObjects", from: "2.1.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-testing", from: "0.1.0"),
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
                .product(name: "TalkerCommon", package: "talkercommon"),
                .product(name: "StreamAudio", package: "StreamAudioPlayer"),
                "AsyncObjects",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .target(name: "MicrosoftCognitiveServicesSpeech"),
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
