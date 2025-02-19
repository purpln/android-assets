// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "AndroidAssets", products: [
    .library(name: "AndroidAssets", targets: ["AndroidAssets"]),
], dependencies: [
    .package(url: "https://github.com/purpln/ndk.git", branch: "main"),
], targets: [
    .target(name: "AndroidAssets", dependencies: [
        .product(name: "NDK", package: "ndk"),
    ]),
])
