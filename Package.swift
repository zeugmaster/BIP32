// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "BIP32",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BIP32",
            targets: ["BIP32"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/anquii/Base58Check.git",
            .exact("1.0.1")
        ),
        .package(
            url: "https://github.com/attaswift/BigInt.git",
            .exact("5.3.0")
        ),
        .package(
            url: "https://github.com/krzyzanowskim/CryptoSwift.git",
            .exact("1.9.0")
        ),
        .package(
            url: "https://github.com/anquii/RIPEMD160.git",
            .exact("1.0.0")
        ),
        .package(name: "swift-secp256k1",
                 url: "https://github.com/21-DOT-DEV/swift-secp256k1",
                 .exact("0.19.0")),
    ],
    targets: [
        .target(
            name: "BIP32",
            dependencies: [
                .product(name: "Base58Check", package: "Base58Check"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "RIPEMD160", package: "RIPEMD160"),
                .product(name: "secp256k1", package: "swift-secp256k1")
            ]
        ),
        .testTarget(
            name: "BIP32Tests",
            dependencies: ["BIP32"]
        )
    ]
)
