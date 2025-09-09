import UIKit
import Sentry

class ViewController: UIViewController {
    
    private var testButton: UIButton!
    private var networkButton: UIButton!
    private var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        testBasicFunctionality()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController viewDidAppear called")
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        if testButton == nil {
            testButton = UIButton(type: .system)
            testButton.setTitle("Test App", for: .normal)
            testButton.backgroundColor = .systemBlue
            testButton.setTitleColor(.white, for: .normal)
            testButton.layer.cornerRadius = 8
            testButton.addTarget(self, action: #selector(testButtonTapped), for: .touchUpInside)
            testButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(testButton)
            
            NSLayoutConstraint.activate([
                testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
                testButton.widthAnchor.constraint(equalToConstant: 200),
                testButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        if networkButton == nil {
            networkButton = UIButton(type: .system)
            networkButton.setTitle("Test Network", for: .normal)
            networkButton.backgroundColor = .systemGreen
            networkButton.setTitleColor(.white, for: .normal)
            networkButton.layer.cornerRadius = 8
            networkButton.addTarget(self, action: #selector(networkButtonTapped), for: .touchUpInside)
            networkButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(networkButton)
            
            NSLayoutConstraint.activate([
                networkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                networkButton.topAnchor.constraint(equalTo: testButton.bottomAnchor, constant: 20),
                networkButton.widthAnchor.constraint(equalToConstant: 200),
                networkButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        if statusLabel == nil {
            statusLabel = UILabel()
            statusLabel.text = "UIKit App with Sentry Integration"
            statusLabel.textAlignment = .center
            statusLabel.numberOfLines = 0
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(statusLabel)
            
            NSLayoutConstraint.activate([
                statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                statusLabel.bottomAnchor.constraint(equalTo: testButton.topAnchor, constant: -20),
                statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
    }
    
    private func testBasicFunctionality() {
        print("Testing basic UIKit functionality")
        statusLabel.text = "UIKit app running successfully!\nSentry integration enabled."
        
        testSentryIntegration()
    }
    
    @objc private func testButtonTapped() {
        print("Test button tapped!")
        
        SentrySDK.capture(message: "Test button tapped")
        
        statusLabel.text = "Button tapped successfully!\nSentry integration enabled."
        
        let alert = UIAlertController(title: "Test Alert", message: "UIKit app is working correctly!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func networkButtonTapped() {
        print("Network button tapped!")
        
        statusLabel.text = "Making network requests...\nCheck Sentry for breadcrumbs!"
        
        performNetworkRequests()
    }
    
    private func testSentryIntegration() {
        SentrySDK.capture(message: "App launched successfully")
        print("Sentry integration test completed")
    }
    
    private func performNetworkRequests() {
        makeGETRequest()
        makePOSTRequest()
        makePUTRequest()
        makeDELETERequest()
    }
    
    private func makeGETRequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default, delegate: NetworkBodyCapture.shared, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("GET Request Error: \(error)")
                    self.statusLabel.text = "Network request failed!\nCheck Sentry breadcrumbs."
                } else if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "No data"
                    print("GET Response: \(responseString)")
                    self.statusLabel.text = "GET request completed!\nCheck Sentry for response body."
                }
            }
        }
        task.resume()
    }
    
    private func makePOSTRequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let postData: [String: Any] = [
            "title": "Sentry Network Test",
            "body": "This is a test POST request with Sentry network tracking",
            "userId": 1
        ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: postData)
            request.httpBody = bodyData
            
            // Create a manual breadcrumb with the request body
            let crumb = Breadcrumb()
            crumb.level = .info
            crumb.category = "manual_network_test"
            crumb.message = "Manual POST Request Test"
            crumb.data = [
                "method": "POST",
                "url": url.absoluteString,
                "request_body": String(data: bodyData, encoding: .utf8) ?? "Unable to decode",
                "test_type": "manual_breadcrumb_test"
            ]
            SentrySDK.addBreadcrumb(crumb)
            print("🔍 Manual breadcrumb added for POST request")
            
            let session = URLSession(configuration: .default, delegate: NetworkBodyCapture.shared, delegateQueue: nil)
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("POST Request Error: \(error)")
                    } else if let data = data {
                        let responseString = String(data: data, encoding: .utf8) ?? "No data"
                        print("POST Response: \(responseString)")
                        
                        // Create a manual breadcrumb with the response body
                        let responseCrumb = Breadcrumb()
                        responseCrumb.level = .info
                        responseCrumb.category = "manual_network_response"
                        responseCrumb.message = "Manual POST Response Test"
                        responseCrumb.data = [
                            "method": "POST",
                            "url": url.absoluteString,
                            "response_body": responseString,
                            "test_type": "manual_response_test"
                        ]
                        SentrySDK.addBreadcrumb(responseCrumb)
                        print("🔍 Manual response breadcrumb added for POST request")
                    }
                }
            }
            
            // Capture the request body
            NetworkBodyCapture.shared.captureRequestBody(for: task, data: bodyData)
            task.resume()
            
        } catch {
            print("Error creating POST data: \(error)")
            return
        }
    }
    
    private func makePUTRequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let putData: [String: Any] = [
            "id": 1,
            "title": "Updated Sentry Network Test",
            "body": "This is a test PUT request with Sentry network tracking",
            "userId": 1
        ]
        
        do {
            let bodyData = try JSONSerialization.data(withJSONObject: putData)
            request.httpBody = bodyData
            
            let session = URLSession(configuration: .default, delegate: NetworkBodyCapture.shared, delegateQueue: nil)
            let task = session.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("PUT Request Error: \(error)")
                    } else if let data = data {
                        let responseString = String(data: data, encoding: .utf8) ?? "No data"
                        print("PUT Response: \(responseString)")
                    }
                }
            }
            
            // Capture the request body
            NetworkBodyCapture.shared.captureRequestBody(for: task, data: bodyData)
            task.resume()
            
        } catch {
            print("Error creating PUT data: \(error)")
            return
        }
    }
    
    private func makeDELETERequest() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default, delegate: NetworkBodyCapture.shared, delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("DELETE Request Error: \(error)")
                } else {
                    print("DELETE Request completed successfully")
                    self.statusLabel.text = "All network requests completed!\nCheck Sentry breadcrumbs for request/response bodies."
                }
            }
        }
        task.resume()
    }
}
