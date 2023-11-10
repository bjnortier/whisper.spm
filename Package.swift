// swift-tools-version:5.3
import PackageDescription

#if arch(arm) || arch(arm64)
let platforms: [SupportedPlatform]? = [
    .macOS(.v11),
    .iOS(.v14),
    .watchOS(.v4),
    .tvOS(.v14)
]
let exclude: [String] = []
let resources: [Resource] = [
    .process("Sources/whisper/ggml-metal.metal")
]
let additionalSources: [String] = ["Sources/whisper/ggml-metal.m"]
let additionalSettings: [CSetting] = [
    .unsafeFlags(["-fno-objc-arc"]),
    .define("GGML_USE_METAL")
]
#else
let platforms: [SupportedPlatform]? = nil
let exclude: [String] = ["Sources/whisper/ggml-metal.metal"]
let resources: [Resource] = []
let additionalSources: [String] = []
let additionalSettings: [CSetting] = []
#endif

let package = Package(
    name: "whisper.spm",
    platforms: platforms,
    products: [
        .library(
            name: "whisper",
            targets: ["whisper"])
    ],
    targets: [
        .target(
            name: "whisper",
            path: ".",
            exclude: exclude,
            sources: [
                "Sources/whisper/ggml.c",
                "Sources/whisper/ggml-alloc.c",
                "Sources/whisper/ggml-backend.c",
                "Sources/whisper/ggml-quants.c",
                "Sources/whisper/whisper.cpp",
            ] + additionalSources,
            resources: resources,
            publicHeadersPath: "Sources/whisper/include",
            cSettings: [
                .unsafeFlags(["-Wno-shorten-64-to-32"]),
                .define("GGML_USE_ACCELERATE"),
            ] + additionalSettings,
            linkerSettings: [
                .linkedFramework("Accelerate")
            ]
        ),
        .target(name: "test-objc",  dependencies:["whisper"]),
        .target(name: "test-swift", dependencies:["whisper"])
    ],
    cxxLanguageStandard: CXXLanguageStandard.cxx11
)
