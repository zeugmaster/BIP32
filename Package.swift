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
            url: "https://github.com/anquii/CryptoSwiftWrapper.git",
            .exact("1.4.3")
        ),
        .package(
            url: "https://github.com/anquii/RIPEMD160.git",
            .exact("1.0.0")
        ),
        .package(
            name: "secp256k1",
            url: "https://github.com/zeugmaster/swift-secp256k1.git",
            branch: "main")
    ],
    targets: [
        .target(
            name: "BIP32",
            dependencies: [
                .product(name: "Base58Check", package: "Base58Check"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "CryptoSwiftWrapper", package: "CryptoSwiftWrapper"),
                .product(name: "RIPEMD160", package: "RIPEMD160"),
                .product(name: "secp256k1", package: "secp256k1")
            ]
        ),
        .testTarget(
            name: "BIP32Tests",
            dependencies: ["BIP32"]
        )
    ]
)
