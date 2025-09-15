import UIKit
import Sentry

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        NSLog("🔍🔍🔍 AppDelegate: Creating window FIRST... 🔍🔍🔍")
        NSLog("🔍 AppDelegate: window property is \(window == nil ? "nil" : "set")")

        // Create window BEFORE Sentry initialization (like customer's setup)
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        NSLog("🔍 AppDelegate: Window setup completed")
        NSLog("🔍 AppDelegate: window property is now \(window == nil ? "nil" : "set")")
        
        NSLog("🔍🔍🔍 AppDelegate: Starting Sentry initialization... 🔍🔍🔍")
        
        SentrySDK.start { options in
            options.dsn = "https://bd03859ac43e47f1a74c83a5a2b8614b@o88872.ingest.us.sentry.io/6748045"
            options.debug = true
            options.tracesSampleRate = 1.0
            options.environment = "sergio-test"
            
            options.beforeBreadcrumb = { crumb in
                if crumb.category == "http" {
                    return self.enhanceHttpBreadcrumb(crumb)
                }
                return crumb
            }
            
            options.beforeSend = { event in
                // Use NSLog instead of print for better visibility
                NSLog("🔍🔍🔍 SENTRY EVENT CAPTURED 🔍🔍🔍")
                NSLog("🔍 Event Type: \(event.type ?? "unknown")")
                NSLog("🔍 Event Level: \(event.level)")
                NSLog("🔍 Event Message: \(event.message?.formatted ?? "No message")")
                
                // Check SDK version
                if let sdk = event.sdk {
                    NSLog("🔍 SDK Info: \(sdk)")
                    let sdkVersion = sdk["version"] as? String ?? "unknown"
                    NSLog("🔍 SDK Version: \(sdkVersion)")
                    
                    if sdkVersion == "8.53.2" {
                        NSLog("✅✅✅ SDK VERSION CONFIRMED: 8.53.2 ✅✅✅")
                    } else {
                        NSLog("❌❌❌ SDK VERSION MISMATCH: Expected 8.53.2, got \(sdkVersion) ❌❌❌")
                    }
                } else {
                    NSLog("❌❌❌ NO SDK INFO FOUND IN EVENT ❌❌❌")
                }
                
                // Output full event JSON for debugging
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: event.serialize(), options: .prettyPrinted)
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        NSLog("🔍 FULL EVENT JSON:")
                        NSLog(jsonString)
                    }
                } catch {
                    NSLog("❌ Failed to serialize event JSON: \(error)")
                }
                
                NSLog("🔍🔍🔍 END SENTRY EVENT 🔍🔍🔍")
                
                // Return the event to send it
                return event
            }
        }
        
        NSLog("🔍 AppDelegate: Sentry initialization completed")
        
        // Trigger a test error to see if beforeSend hook is called
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSLog("🔍 Triggering test error to test beforeSend hook...")
            SentrySDK.capture(message: "Test error to validate beforeSend hook and SDK version")
        }

        return true
    }

    
    private func enhanceHttpBreadcrumb(_ crumb: Breadcrumb) -> Breadcrumb {
        // Create a mutable copy of the breadcrumb
        var enhancedCrumb = crumb
        
        // Add custom data to the breadcrumb
        if enhancedCrumb.data == nil {
            enhancedCrumb.data = [:]
        }
        
        // Add network body information if available
        if let url = enhancedCrumb.data?["url"] as? String {
            enhancedCrumb.data?["network_body_info"] = "Request/response bodies captured via beforeBreadcrumb hook"
            enhancedCrumb.data?["enhanced_by"] = "custom_breadcrumb_enhancement"
            
            // Add specific information based on the URL
            if url.contains("jsonplaceholder.typicode.com") {
                enhancedCrumb.data?["api_service"] = "JSONPlaceholder"
                enhancedCrumb.data?["test_request"] = true
                
                // Add mock request/response bodies for demonstration
                if let method = enhancedCrumb.data?["method"] as? String {
                    switch method {
                    case "GET":
                        enhancedCrumb.data?["request_body"] = "No request body (GET request)"
                        enhancedCrumb.data?["response_body"] = "{\"id\":1,\"title\":\"sunt aut facere repellat provident occaecati excepturi optio reprehenderit\",\"body\":\"quia et suscipit\\nsuscipit recusandae consequuntur expedita et cum reprehenderit molestiae ut ut quas totam\\nnostrum rerum est autem sunt rem eveniet architecto\",\"userId\":1}"
                    case "POST":
                        enhancedCrumb.data?["request_body"] = "{\"title\":\"Sentry Network Test\",\"body\":\"This is a test POST request with Sentry network tracking\",\"userId\":1}"
                        enhancedCrumb.data?["response_body"] = "{\"id\":101,\"title\":\"Sentry Network Test\",\"body\":\"This is a test POST request with Sentry network tracking\",\"userId\":1}"
                    case "PUT":
                        enhancedCrumb.data?["request_body"] = "{\"id\":1,\"title\":\"Updated Sentry Network Test\",\"body\":\"This is a test PUT request with Sentry network tracking\",\"userId\":1}"
                        enhancedCrumb.data?["response_body"] = "{\"id\":1,\"title\":\"Updated Sentry Network Test\",\"body\":\"This is a test PUT request with Sentry network tracking\",\"userId\":1}"
                    case "DELETE":
                        enhancedCrumb.data?["request_body"] = "No request body (DELETE request)"
                        enhancedCrumb.data?["response_body"] = "{}"
                    default:
                        enhancedCrumb.data?["request_body"] = "Unknown method"
                        enhancedCrumb.data?["response_body"] = "Unknown method"
                    }
                }
            }
        }
        
        return enhancedCrumb
    }
}
