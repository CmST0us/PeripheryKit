import PackagePlugin
import Foundation

@main
struct CopySysrootHeader: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let outputDir = context.pluginWorkDirectory
        let configFile = context.package.directory.appending(subpath: "Config.json")
        let config = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: configFile.string))) as! [String: String]
        let sysrootPath = Path(config["sysroot-path"]!)
        let srcCopyPath = sysrootPath.appending(subpath: "usr/include")

        if FileManager.default.fileExists(atPath: outputDir.appending(subpath: "include").string) {
            try! FileManager.default.removeItem(atPath: outputDir.appending(subpath: "include").string)
        }
        return [
            .prebuildCommand(
                displayName: "CopySysrootHeader",
                executable: Path("/bin/cp"),
                arguments: [
                    "-rvf",
                    srcCopyPath,
                    outputDir.string
                ],
                outputFilesDirectory: outputDir)
        ]
    }
}
