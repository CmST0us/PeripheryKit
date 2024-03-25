// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let sysrootHeaderSearchPath = "../../.build/plugins/outputs/peripherykit/Cperiphery/PeripheryKitCopySysrootHeader/include"

enum CDEVVersion {
    case none
    case v1
    case v2
}
let versionOfCDEV: CDEVVersion = .v1
var defineOfCDEV: String {
    switch versionOfCDEV {
    case .none:
        return ""
    case .v1:
        return "PERIPHERY_GPIO_CDEV_SUPPORT=1"
    case .v2:
        return "PERIPHERY_GPIO_CDEV_SUPPORT=2"
    }
}

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
            dependencies: ["PeripheryKitCopySysrootHeader"],
            cSettings: [
                .headerSearchPath(sysrootHeaderSearchPath),
                .define(defineOfCDEV)
            ]),
        
        .target(
            name: "PeripheryKit",
            dependencies: ["Cperiphery"]),
        .testTarget(
            name: "PeripheryKitTests",
            dependencies: ["PeripheryKit"]),
        
        .executableTarget(name: "pio",
                          dependencies: [
                            "PeripheryKit"]),
    
        .plugin(
            name: "PeripheryKitCopySysrootHeader",
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
