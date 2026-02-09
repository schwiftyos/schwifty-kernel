// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "schwifty-kernel",
    products: [
        .library(
            name: "Kernel",
            type: .static,
            targets: ["Kernel"]
        )
    ],
    traits: [
    ],
    targets: [
        .target(
            name: "Kernel",
            swiftSettings: [
                .enableExperimentalFeature("Extern"),
                .enableExperimentalFeature("Embedded"),
                .strictMemorySafety(),
                .unsafeFlags([
                    "-Xfrontend", "-disable-stack-protector",
                    "-wmo"
                ])
            ]
        ),
        .testTarget(
            name: "schwifty-kernelTests",
            dependencies: ["Kernel"]
        )
    ]
)
