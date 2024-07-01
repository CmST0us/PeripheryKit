import PackagePlugin
import Foundation

@main
struct DownloadCPeriphery: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let outputDir = context.pluginWorkDirectory
        let cperipheryDir = try! context.package.targets(named: ["Cperiphery"]).first!.directory
        let version = arguments[0]
        do {
            try Process.run(URL(fileURLWithPath: "/usr/bin/curl"), arguments: [
                "https://codeload.github.com/CmST0us/c-periphery/tar.gz/refs/tags/v\(version)",
                "--compressed",
                "-o",
                "\(outputDir.appending(subpath: "c-periphery.tar.gz"))"
            ]).waitUntilExit()
            
            try Process.run(URL(fileURLWithPath: "/usr/bin/tar"), arguments: [
                "xf",
                "\(outputDir.appending(subpath: "c-periphery.tar.gz"))",
                "-C",
                "\(outputDir.string)"
            ]).waitUntilExit()

            try FileManager.default.contentsOfDirectory(atPath: "\(outputDir.appending(subpath:"c-periphery-\(version)"))/src/")
                .filter { content in
                    if (Path(content).extension ?? "") == "h" {
                        return true
                    }
                    return false
                }.map { content in
                    return "\(outputDir.appending(subpath:"c-periphery-\(version)"))/src/\(content)"
                }.forEach { contentPath in
                    try Process.run(URL(fileURLWithPath: "/bin/cp"), arguments: [
                        "-f",
                        contentPath,
                        "\(cperipheryDir)/include"
                    ]).waitUntilExit()
                }
            
            try FileManager.default.contentsOfDirectory(atPath: "\(outputDir.appending(subpath:"c-periphery-\(version)"))/src/")
                .filter { content in
                    if (Path(content).extension ?? "") == "c" {
                        return true
                    }
                    return false
                }.map { content in
                    return "\(outputDir.appending(subpath:"c-periphery-\(version)"))/src/\(content)"
                }.forEach { contentPath in
                    try Process.run(URL(fileURLWithPath: "/bin/cp"), arguments: [
                        "-f",
                        contentPath,
                        "\(cperipheryDir)/"
                    ]).waitUntilExit()
                }
        } catch {
            throw error
        }
    }
}
