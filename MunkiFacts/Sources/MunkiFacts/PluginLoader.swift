import Foundation
import Darwin
import MunkiFactsInterface

typealias PluginInitializer = @convention(c) () -> UnsafeMutableRawPointer

class PluginLoader {
    private let pluginDirectory: String

    init(pluginDirectory: String) {
        self.pluginDirectory = pluginDirectory
    }

    func loadPlugins() -> [FactPlugin] {
        var plugins: [FactPlugin] = []

        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: pluginDirectory)
            for file in files where file.hasSuffix(".plugin") {
                let pluginPath = (pluginDirectory as NSString).appendingPathComponent(file)
                print("Attempting to load plugin: \(file)")

                guard let handle = dlopen(pluginPath, RTLD_NOW) else {
                    if let error = dlerror() {
                        print("Failed to load plugin \(file): \(String(cString: error))")
                    }
                    continue
                }

                guard let symbolPtr = dlsym(handle, "createPlugin") else {
                    print("Failed to find createPlugin symbol in \(file)")
                    dlclose(handle)
                    continue
                }

                let initializer = unsafeBitCast(symbolPtr, to: PluginInitializer.self)
                let pluginPtr = initializer()

                let plugin = Unmanaged<AnyObject>.fromOpaque(pluginPtr).takeRetainedValue()
                guard let factPlugin = plugin as? FactPlugin else {
                    print("Failed to cast plugin instance for \(file)")
                    continue
                }

                print("Successfully loaded plugin: \(file)")
                plugins.append(factPlugin)
            }
        } catch {
            print("Error scanning plugin directory: \(error)")
        }

        return plugins
    }
}
