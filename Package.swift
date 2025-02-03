// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "jplFuzzer",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "jplFuzzer", targets: ["jplFuzzer"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "jplFuzzer",
            dependencies: [],
            path: "src",
            swiftSettings: [
                .unsafeFlags(
                    [
                        "-O", "-whole-module-optimization", "-cross-module-optimization",
                        "-lto=llvm-full",
                    ],
                    .when(configuration: .release)),
                .unsafeFlags([], .when(configuration: .debug)),
            ]
        )
    ]
)
