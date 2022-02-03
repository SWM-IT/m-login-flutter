import AuthenticationServices
import SafariServices
import Flutter
import UIKit

public class SwiftMLoginSdkPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "m_login_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftMLoginSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "authenticate" {
            let url = URL(string: (call.arguments as! Dictionary<String, AnyObject>)["url"] as! String)!
            let callbackURLScheme = (call.arguments as! Dictionary<String, AnyObject>)["callbackUrlScheme"] as! String

            // The session MUST be stored by us somewhere. If not, it will be ARC released immediately
            // after we call `start` on it.
            // Then released once the sessions concludes.
            var sessionToKeepAlive: Any? = nil
            
            let completionHandler = {  (url: URL?, err: Error?) in
                sessionToKeepAlive = nil
                
                guard err == nil else {
                    processError(err!, result)
                    return
                }
                
                result(url!.absoluteString)
            }
            
            if #available(iOS 12, *) {
                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                
                if #available(iOS 13, *) {
                    guard let provider = UIApplication.shared.delegate?.window??.rootViewController as? FlutterViewController else {
                        result(FlutterError(code: "FAILED", message: "Failed to aquire root FlutterViewController" , details: nil))
                        return
                    }
                    
                    session.prefersEphemeralWebBrowserSession = true
                    session.presentationContextProvider = provider
                }
                
                session.start()
                sessionToKeepAlive = session
            } else if #available(iOS 11, *) {
                let session = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
                session.start()
                sessionToKeepAlive = session
            } else {
                result(FlutterError(code: "FAILED", message: "This plugin does currently not support iOS lower than iOS 11" , details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    
}

fileprivate func processError(_ err: Error, _ result: FlutterResult){
    if #available(iOS 12, *) {
        if case ASWebAuthenticationSessionError.canceledLogin = err {
            result(FlutterError(code: "CANCELED", message: "User canceled login", details: nil))
            return
        }
    }
    
    if #available(iOS 11, *) {
        if case SFAuthenticationError.canceledLogin = err {
            result(FlutterError(code: "CANCELED", message: "User canceled login", details: nil))
            return
        }
    }
    
    result(FlutterError(code: "UNKNOWN", message: err.localizedDescription, details: nil))
}

@available(iOS 13, *)
extension FlutterViewController: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.view.window!
    }
}
