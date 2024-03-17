import PackagePlugin
import Foundation

@main
struct DownloadCPeriphery: CommandPlugin {
    func performCommand(context: PackagePlugin.PluginContext, arguments: [String]) async throws {
        let configFile = context.package.directory.appending(subpath: "Config.json")
        let config = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: configFile.string))) as! [String: String]
        let version = config["c-periphery-version"]!
        let outputDir = context.pluginWorkDirectory
        let cperipheryDir = try! context.package.targets(named: ["Cperiphery"]).first!.directory
        
        do {
            try Process.run(URL(fileURLWithPath: "/usr/bin/curl"), arguments: [
                "https://codeload.github.com/vsergeev/c-periphery/tar.gz/refs/tags/v\(version)",
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
            
            // Patch File
            var fileContent = try! String(contentsOfFile: "\(cperipheryDir)/include/gpio_internal.h")
            
            let stringToInsertAfterStdarg = "\n#include <stdio.h>"
            let stringToInsertAfterStdio = "\n#include <string.h>"

            if let rangeOfStdarg = fileContent.range(of: "#include <stdarg.h>") {
                fileContent.insert(contentsOf: stringToInsertAfterStdarg, at: rangeOfStdarg.upperBound)
            }
            if let rangeOfStdio = fileContent.range(of: "#include <stdio.h>") {
                fileContent.insert(contentsOf: stringToInsertAfterStdio, at: rangeOfStdio.upperBound)
            }
            
            try! fileContent.write(toFile: "\(cperipheryDir)/include/gpio_internal.h", atomically: true, encoding: .utf8)
        } catch {
            throw error
        }
    }
}
