//
//  MainViewController.swift
//  VoiceKeyboard
//
//  Created by iOS Developer on Voice-to-Text Keyboard Project
//

import UIKit

class MainViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎤 Voice-to-Text Keyboard"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = """
        Setup Instructions:
        
        1. Go to Settings → General → Keyboard
        2. Tap "Keyboards" then "Add New Keyboard"
        3. Select "Voice Keyboard" under Third-Party Keyboards
        4. ⚠️ IMPORTANT: Tap "Voice Keyboard" again and enable "Allow Full Access"
        5. Test in any text field by switching keyboards (🌐 globe icon)
        
        How to Use:
        • Press and hold the microphone button to record
        • Speak your message clearly
        • Release to stop recording and get transcription
        • Text will be inserted automatically
        """
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let testTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Tap here to test your voice keyboard"
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemBlue.cgColor
        textField.layer.cornerRadius = 8
        return textField
    }()
    
    private let testTextView: UITextView = {
        let textView = UITextView()
        textView.text = "Or test in this larger text area..."
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.systemBlue.cgColor
        textView.layer.cornerRadius = 8
        textView.textColor = .placeholderText
        return textView
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Keyboard Settings", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Status: Keyboard not configured yet"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemOrange
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        checkKeyboardStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkKeyboardStatus()
    }
    
    private func setupUI() {
        title = "Voice Keyboard Setup"
        view.backgroundColor = .systemBackground
        
        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add all subviews to content view
        contentView.addSubview(titleLabel)
        contentView.addSubview(instructionsLabel)
        contentView.addSubview(testTextField)
        contentView.addSubview(testTextView)
        contentView.addSubview(settingsButton)
        contentView.addSubview(statusLabel)
        
        // Setup constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        testTextField.translatesAutoresizingMaskIntoConstraints = false
        testTextView.translatesAutoresizingMaskIntoConstraints = false
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Instructions
            instructionsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Test text field
            testTextField.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 30),
            testTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Test text view
            testTextView.topAnchor.constraint(equalTo: testTextField.bottomAnchor, constant: 20),
            testTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            testTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            testTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Settings button
            settingsButton.topAnchor.constraint(equalTo: testTextView.bottomAnchor, constant: 30),
            settingsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            settingsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            settingsButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        settingsButton.addTarget(self, action: #selector(openKeyboardSettings), for: .touchUpInside)
        
        // Text view delegate setup
        testTextView.delegate = self
    }
    
    @objc private func openKeyboardSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    private func checkKeyboardStatus() {
        // This is a simple check - in a real app you might want to check if your keyboard is actually enabled
        let hasFullAccess = UIPasteboard.general.hasStrings || UIPasteboard.general.hasImages
        
        if hasFullAccess {
            statusLabel.text = "Status: ✅ Keyboard configured and ready!"
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = "Status: ⚠️ Please enable keyboard and full access"
            statusLabel.textColor = .systemOrange
        }
    }
}

// MARK: - UITextViewDelegate
extension MainViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Or test in this larger text area..."
            textView.textColor = .placeholderText
        }
    }
}