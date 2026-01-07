// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "VaultChat",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "VaultChat",
            targets: ["VaultChat"]
        )
    ],
    targets: [
        .target(
            name: "VaultChat",
            path: "VaultChat",
            resources: [
                .process("Info.plist")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
