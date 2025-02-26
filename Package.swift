// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "AndroidAssets", products: [
    .library(name: "AndroidAssets", targets: ["AndroidAssets"]),
], targets: [
    .target(name: "AndroidAssets"),
])
