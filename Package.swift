// swift-tools-version:6.2

import PackageDescription

let swiftSettings:[SwiftSetting] = [
    .enableExperimentalFeature("LifetimeDependence"),
    .enableExperimentalFeature("SymbolLinkageMarkers"),
    .enableExperimentalFeature("Extern"),
    .unsafeFlags(["-strict-memory-safety"])
]

let package = Package(
    name: "schwifty-kernel",
    products: [
        .executable(
            name: "Kernel",
            targets: ["Kernel"]
        )
    ],
    traits: [
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-mmio", from: "0.1.1"),
    ],
    targets: [
        .executableTarget(
            name: "Kernel",
            dependencies: [
                .product(name: "MMIO", package: "swift-mmio")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "schwifty-kernelTests",
            dependencies: ["Kernel"]
        )
    ]
)
