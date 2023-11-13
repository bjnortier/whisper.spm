// swift-tools-version:5.3
import PackageDescription

#if arch(arm) || arch(arm64)
let platforms: [SupportedPlatform]? = [
    .macOS(.v11),
    .iOS(.v14),
    .watchOS(.v4),
    .tvOS(.v14)
]

let exclude: [String] = ["coreml"]
let additionalSettings: [CSetting] = [
    .unsafeFlags(["-fno-objc-arc"]),
    .define("GGML_USE_METAL")
]
// let resources: [Resource] = [
//    .process("ggml-metal.metal")
// ]
#else
let platforms: [SupportedPlatform]? = nil
let exclude: [String] = ["Sources/whisper/ggml-metal.m", "Sources/whisper/ggml-metal.metal"]
let additionalSettings: [CSetting] = []
#endif

let package = Package(
    name: "whisper.spm",
    platforms: platforms,
    products: [
        .library(
            name: "whisper",
            targets: ["whisper"]
        )
    ],
    targets: [
        .target(
            name: "metal-lib",
            resources: [
                .process("ggml-metal.metal")
            ]
        ),
        .target(
            name: "whisper",
            dependencies: ["metal-lib"],
            exclude: exclude,
            publicHeadersPath: "include",
            cSettings: [
                .unsafeFlags(["-Wno-shorten-64-to-32"]),
                .define("GGML_USE_ACCELERATE")
            ] + additionalSettings,
            cxxSettings: [
                .unsafeFlags(["-Wno-shorten-64-to-32"]),
                .define("GGML_USE_ACCELERATE"),
                .unsafeFlags(["-fno-objc-arc"]),
                .define("GGML_USE_METAL")
            ],
            linkerSettings: [
                .linkedFramework("Accelerate")
            ]
        ),
        .target(name: "test-objc", dependencies: ["whisper"]),
        .target(name: "test-swift", dependencies: ["whisper"])
    ],
    cxxLanguageStandard: CXXLanguageStandard.cxx11
)
