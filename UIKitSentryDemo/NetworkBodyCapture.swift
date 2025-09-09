import Foundation
import Sentry

class NetworkBodyCapture: NSObject, URLSessionDataDelegate {
    static let shared = NetworkBodyCapture()
    
    private var requestBodies: [URLSessionTask: Data] = [:]
    private var responseBodies: [URLSessionTask: Data] = [:]
    
    private override init() {
        super.init()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Create a custom breadcrumb with the network bodies
        let crumb = Breadcrumb()
        crumb.level = .info
        crumb.category = "http"
        crumb.message = "\(task.originalRequest?.httpMethod ?? "UNKNOWN") \(task.originalRequest?.url?.absoluteString ?? "unknown")"
        
        var data: [String: Any] = [
            "method": task.originalRequest?.httpMethod ?? "UNKNOWN",
            "url": task.originalRequest?.url?.absoluteString ?? "unknown",
            "status_code": (task.response as? HTTPURLResponse)?.statusCode ?? 0,
            "enhanced_by": "custom_network_capture",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Add request body if available
        if let requestBody = requestBodies[task] {
            let requestBodyString = String(data: requestBody, encoding: .utf8) ?? "Unable to decode request body"
            data["request_body"] = requestBodyString
        } else {
            data["request_body"] = "No request body (GET/DELETE request)"
        }
        
        // Add response body if available
        if let responseBody = responseBodies[task] {
            let responseBodyString = String(data: responseBody, encoding: .utf8) ?? "Unable to decode response body"
            data["response_body"] = responseBodyString
        } else {
            data["response_body"] = "No response body captured"
        }
        
        crumb.data = data
        
        // Debug logging
        print("🔍 NetworkBodyCapture: Creating breadcrumb for \(data["method"] ?? "UNKNOWN") request")
        print("🔍 Request body available: \(requestBodies[task] != nil)")
        print("🔍 Response body available: \(responseBodies[task] != nil)")
        print("🔍 Request body: \(data["request_body"] ?? "N/A")")
        print("🔍 Response body: \(data["response_body"] ?? "N/A")")
        
        // Use a different category to avoid conflicts with Sentry's automatic HTTP breadcrumbs
        crumb.category = "network_body_capture"
        crumb.message = "Custom Network Body Capture - \(data["method"] ?? "UNKNOWN") \(data["url"] ?? "unknown")"
        
        SentrySDK.addBreadcrumb(crumb)
        
        // Clean up
        requestBodies.removeValue(forKey: task)
        responseBodies.removeValue(forKey: task)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // Accumulate response data
        if responseBodies[dataTask] == nil {
            responseBodies[dataTask] = Data()
        }
        responseBodies[dataTask]?.append(data)
    }
    
    func captureRequestBody(for task: URLSessionTask, data: Data) {
        requestBodies[task] = data
    }
}
