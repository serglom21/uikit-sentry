import UIKit
import Sentry

class ViewController: UIViewController {
    
    private var testButton: UIButton!
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
                testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                testButton.widthAnchor.constraint(equalToConstant: 200),
                testButton.heightAnchor.constraint(equalToConstant: 50)
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
    
    private func testSentryIntegration() {
        SentrySDK.capture(message: "App launched successfully")
        print("Sentry integration test completed")
    }
}
