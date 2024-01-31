// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sysrootHeaderSearchPath = "../../.build/plugins/outputs/peripherykit/Cperiphery/CopySysrootHeader/include"

let package = Package(
    name: "PeripheryKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PeripheryKit",
            targets: ["PeripheryKit"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Cperiphery",
            dependencies: ["CopySysrootHeader"],
            cSettings: [
                .headerSearchPath(sysrootHeaderSearchPath)
            ]),
        
        .target(
            name: "PeripheryKit",
            dependencies: ["Cperiphery"]),
        .testTarget(
            name: "PeripheryKitTests",
            dependencies: ["PeripheryKit"]),
        
        .executableTarget(name: "pio",
                          dependencies: ["PeripheryKit"]),
    
        .plugin(
            name: "CopySysrootHeader",
            capability: .buildTool()
        ),
        .plugin(name: "DownloadCPeriphery",
                capability: .command(
                    intent: .custom(verb: "download-c-periphery", description: "Download c-periphery"),
                    permissions: [
                        .allowNetworkConnections(scope: .all(ports: [443]), reason: "Download packages"),
                        .writeToPackageDirectory(reason: "Write packages")
                    ]))
    ]
)
