// swift-tools-version:6.0
// VoiceCoder - Voice to code with Whisper

import PackageDescription

let package = Package(
    name: "VoiceCoder",
    platforms: [.macOS(.v15)],
    products: [.executable(name: "voicecoder", targets: ["VoiceCoder"])],
    targets: [.executableTarget(name: "VoiceCoder", swiftSettings: [.swiftLanguageMode(.v6)])]
)
