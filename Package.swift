// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "LevelDatabase", products: [
    .library(name: "LevelDatabase", targets: ["LevelDatabase"]),
], dependencies: [
    .package(url: "https://github.com/purpln/leveldb.git", branch: "main"),
    .package(url: "https://github.com/purpln/tinyfoundation.git", branch: "main"),
], targets: [
    .target(name: "LevelDatabase", dependencies: [
        .product(name: "leveldb", package: "leveldb"),
        .product(name: "TinyFoundation", package: "tinyfoundation"),
    ]),
])
