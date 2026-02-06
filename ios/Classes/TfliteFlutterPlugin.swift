import Flutter
import UIKit

public class TfliteFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    // Force load custom ops to prevent linker from stripping them
    TfliteCustomOpsLoader.loadCustomOps()

    let channel = FlutterMethodChannel(name: "tflite_flutter", binaryMessenger: registrar.messenger())
    let instance = TfliteFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
