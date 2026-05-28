import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
    
    override func application(_ application: NSApplication, open urls: [URL]) {
        if let url = urls.first {
            print("🔵 AppDelegate received URI: \(url.absoluteString)")
            
            let flutterViewController = mainFlutterWindow!.contentViewController as! FlutterViewController
               let channel = FlutterMethodChannel(name: "app.channel.uri",
                                                  binaryMessenger: flutterViewController.engine.binaryMessenger)
               channel.invokeMethod("onUri", arguments: url.absoluteString)
        }
    }
}
