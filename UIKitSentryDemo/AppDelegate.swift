import UIKit
import Sentry

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        SentrySDK.start { options in
            options.dsn = "https://bd03859ac43e47f1a74c83a5a2b8614b@o88872.ingest.us.sentry.io/6748045"
            options.debug = true
            options.tracesSampleRate = 1.0
            
            options.beforeBreadcrumb = { crumb in
                if crumb.category == "http" {
                    return self.enhanceHttpBreadcrumb(crumb)
                }
                return crumb
            }
        }

        window = UIWindow(frame: UIScreen.main.bounds)

        let viewController = ViewController()
        let navigationController = UINavigationController(rootViewController: viewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
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
