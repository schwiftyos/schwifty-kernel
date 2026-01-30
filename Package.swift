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
    targets: [
        .executableTarget(
            name: "Kernel",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "schwifty-kernelTests",
            dependencies: ["Kernel"]
        )
    ]
)
