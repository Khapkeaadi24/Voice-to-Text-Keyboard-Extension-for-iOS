//
//  KeyboardViewController.swift
//  VoiceKeyboardExtension
//
//  Created by iOS Developer on Voice-to-Text Keyboard Project
//

import UIKit
import AVFoundation

class KeyboardViewController: UIInputViewController {
    
    // MARK: - Properties
    private var audioRecorder: AVAudioRecorder?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var recordingURL: URL?
    
    private let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🎤 Hold to Record", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Ready to record"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .systemBlue
        return indicator
    }()
    
    private let waveformView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    private var waveformLayers: [CAShapeLayer] = []
    private var isRecording = false
    private var isProcessing = false
    private var recordingTimer: Timer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudioSession()
        requestMicrophonePermission()
        createWaveformLayers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkMicrophonePermission()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemGray6 : .systemGray5
        
        // Add subviews
        view.addSubview(recordButton)
        view.addSubview(statusLabel)
        view.addSubview(activityIndicator)
        view.addSubview(waveformView)
        
        // Setup constraints
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Record button
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            recordButton.widthAnchor.constraint(equalToConstant: 220),
            recordButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Waveform view
            waveformView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waveformView.bottomAnchor.constraint(equalTo: recordButton.topAnchor, constant: -10),
            waveformView.widthAnchor.constraint(equalToConstant: 200),
            waveformView.heightAnchor.constraint(equalToConstant: 30),
            
            // Status label
            statusLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            // Activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 5)
        ])
        
        // Setup gesture recognizers
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.1
        longPress.allowableMovement = 50
        recordButton.addGestureRecognizer(longPress)
        
        // Set keyboard height
        setupKeyboardHeight()
    }
    
    private func setupKeyboardHeight() {
        let heightConstraint = NSLayoutConstraint(
            item: view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 160
        )
        heightConstraint.priority = .defaultHigh
        view.addConstraint(heightConstraint)
    }
    
    private func createWaveformLayers() {
        waveformLayers.removeAll()
        
        let numberOfBars = 8
        let barWidth: CGFloat = 3
        let barSpacing: CGFloat = 4
        let totalWidth = CGFloat(numberOfBars) * barWidth + CGFloat(numberOfBars - 1) * barSpacing
        let startX = (200 - totalWidth) / 2
        
        for i in 0..<numberOfBars {
            let layer = CAShapeLayer()
            layer.fillColor = UIColor.systemBlue.cgColor
            layer.cornerRadius = barWidth / 2
            
            let x = startX + CGFloat(i) * (barWidth + barSpacing)
            layer.frame = CGRect(x: x, y: 15, width: barWidth, height: 2)
            
            waveformView.layer.addSublayer(layer)
            waveformLayers.append(layer)
        }
    }
    
    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
            updateStatus("Audio setup failed")
        }
    }
    
    // MARK: - Permissions
    private func requestMicrophonePermission() {
        audioSession.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.handleMicrophonePermission(granted: granted)
            }
        }
    }
    
    private func checkMicrophonePermission() {
        let permission = audioSession.recordPermission
        handleMicrophonePermission(granted: permission == .granted)
    }
    
    private func handleMicrophonePermission(granted: Bool) {
        if granted {
            updateStatus("Ready to record")
            recordButton.isEnabled = true
            recordButton.alpha = 1.0
        } else {
            updateStatus("Microphone permission required")
            recordButton.isEnabled = false
            recordButton.alpha = 0.5
        }
    }
    
    // MARK: - Recording Actions
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startRecording()
        case .ended, .cancelled, .failed:
            stopRecording()
        default:
            break
        }
    }
    
    private func startRecording() {
        guard !isRecording && !isProcessing && recordButton.isEnabled else { return }
        
        // Haptic feedback for recording start
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Create temporary file URL
        let documentsPath = FileManager.default.temporaryDirectory
        let timestamp = Int(Date().timeIntervalSince1970)
        recordingURL = documentsPath.appendingPathComponent("voice_recording_\(timestamp).wav")
        
        // Audio recorder settings optimized for Whisper API
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVSampleRateKey: 16000.0,  // 16kHz for Whisper API
            AVNumberOfChannelsKey: 1,   // Mono
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false
        ]
        
        do {
            guard let url = recordingURL else { return }
            
            // Ensure audio session is active
            try audioSession.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() == true {
                isRecording = true
                updateRecordingUI(recording: true)
                startWaveformAnimation()
                
                // Start metering timer
                recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                    self?.updateMetering()
                }
            } else {
                throw NSError(domain: "RecordingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to start recording"])
            }
            
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
            updateStatus("Recording failed: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    private func stopRecording() {
        guard isRecording else { return }
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        audioRecorder?.stop()
        isRecording = false
        
        stopWaveformAnimation()
        updateRecordingUI(recording: false)
        
        // Haptic feedback for recording stop
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Start transcription process
        transcribeAudio()
    }
    
    private func updateMetering() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        
        recorder.updateMeters()
        let averagePower = recorder.averagePower(forChannel: 0)
        
        // Update waveform based on audio levels
        updateWaveformWithLevel(averagePower)
    }
    
    // MARK: - Waveform Animation
    private func startWaveformAnimation() {
        waveformView.isHidden = false
        
        for (index, layer) in waveformLayers.enumerated() {
            let animation = CABasicAnimation(keyPath: "bounds.size.height")
            animation.fromValue = 2
            animation.toValue = 20
            animation.duration = 0.3 + Double(index) * 0.1
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            layer.add(animation, forKey: "waveform")
        }
    }
    
    private func stopWaveformAnimation() {
        waveformView.isHidden = true
        
        for layer in waveformLayers {
            layer.removeAllAnimations()
        }
    }
    
    private func updateWaveformWithLevel(_ level: Float) {
        let normalizedLevel = max(0, (level + 60) / 60) // Normalize -60db to 0db range
        
        for layer in waveformLayers {
            let height = 2 + (normalizedLevel * 18) // 2 to 20 height range
            layer.bounds.size.height = CGFloat(height)
        }
    }
    
    // MARK: - UI Updates
    private func updateRecordingUI(recording: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if recording {
                self.recordButton.backgroundColor = .systemRed
                self.recordButton.setTitle("🔴 Recording...", for: .normal)
                self.statusLabel.text = "Hold to continue recording"
                
                // Pulsing animation
                UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
                    self.recordButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                })
                
            } else {
                self.recordButton.layer.removeAllAnimations()
                self.recordButton.transform = .identity
                self.recordButton.backgroundColor = .systemBlue
                self.recordButton.setTitle("🎤 Hold to Record", for: .normal)
                self.statusLabel.text = "Processing..."
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    private func updateStatus(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusLabel.text = message
        }
    }
    
    // MARK: - Transcription
    private func transcribeAudio() {
        guard let audioURL = recordingURL else {
            updateStatus("No audio file found")
            resetToIdleState()
            return
        }
        
        // Check if file exists and has content
        do {
            let fileSize = try audioURL.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            if fileSize < 1000 { // Less than 1KB probably means no audio
                updateStatus("Recording too short")
                resetToIdleState()
                return
            }
        } catch {
            updateStatus("Error reading audio file")
            resetToIdleState()
            return
        }
        
        isProcessing = true
        
        // Create the API request
        guard let apiURL = URL(string: "https://api.groq.com/openai/v1/audio/transcriptions") else {
            updateStatus("Invalid API URL")
            resetToIdleState()
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 30.0
        
        // IMPORTANT: Replace with your actual Groq API key
        let apiKey = "YOUR_GROQ_API_KEY_HERE"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form data
        var body = Data()
        
        // Add model parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-large-v3\r\n".data(using: .utf8)!)
        
        // Add response format parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"response_format\"\r\n\r\n".data(using: .utf8)!)
        body.append("json\r\n".data(using: .utf8)!)
        
        // Add audio file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/wav\r\n\r\n".data(using: .utf8)!)
        
        do {
            let audioData = try Data(contentsOf: audioURL)
            body.append(audioData)
        } catch {
            print("Failed to read audio file: \(error.localizedDescription)")
            updateStatus("Failed to read audio file")
            resetToIdleState()
            return
        }
        
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        // Send the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleTranscriptionResponse(data: data, response: response, error: error)
            }
        }
        
        task.resume()
    }
    
    private func handleTranscriptionResponse(data: Data?, response: URLResponse?, error: Error?) {
        isProcessing = false
        activityIndicator.stopAnimating()
        
        // Handle network error
        if let error = error {
            print("Network error: \(error.localizedDescription)")
            if error.localizedDescription.contains("Internet connection") {
                updateStatus("No internet connection")
            } else {
                updateStatus("Network error")
            }
            resetToIdleState()
            return
        }
        
        // Check HTTP response
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 401 {
                updateStatus("Invalid API key")
                resetToIdleState()
                return
            } else if httpResponse.statusCode != 200 {
                updateStatus("API error (\(httpResponse.statusCode))")
                resetToIdleState()
                return
            }
        }
        
        // Handle response data
        guard let data = data else {
            updateStatus("No response data")
            resetToIdleState()
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let text = json?["text"] as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                insertTranscribedText(text.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                // Check for API error message
                if let error = json?["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    updateStatus("API Error: \(message)")
                } else {
                    updateStatus("No speech detected")
                }
                resetToIdleState()
            }
            
        } catch {
            print("JSON parsing error: \(error.localizedDescription)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")
            updateStatus("Invalid response format")
            resetToIdleState()
        }
    }
    
    // MARK: - Text Insertion
    private func insertTranscribedText(_ text: String) {
        // Insert the transcribed text
        textDocumentProxy.insertText(text)
        
        // Add a space after the text for better UX
        if !text.hasSuffix(" ") && !text.hasSuffix(".") && !text.hasSuffix("!") && !text.hasSuffix("?") {
            textDocumentProxy.insertText(" ")
        }
        
        updateStatus("✓ Text inserted successfully")
        
        // Success haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Brief success indication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.resetToIdleState()
        }
        
        cleanupAudioFile()
    }
    
    private func resetToIdleState() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.updateStatus("Ready to record")
            self.recordButton.backgroundColor = .systemBlue
            self.recordButton.setTitle("🎤 Hold to Record", for: .normal)
            self.recordButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.isProcessing = false
            self.isRecording = false
        }
        
        cleanupAudioFile()
    }
    
    private func cleanupAudioFile() {
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
            recordingURL = nil
        }
    }
    
    // MARK: - Keyboard Lifecycle
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Ensure consistent keyboard height
        if let heightConstraint = view.constraints.first(where: { $0.firstAttribute == .height }) {
            heightConstraint.constant = 160
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Handle dark/light mode changes
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            view.backgroundColor = traitCollection.userInterfaceStyle == .dark ? .systemGray6 : .systemGray5
        }
    }
    
    // MARK: - Memory Management
    deinit {
        recordingTimer?.invalidate()
        audioRecorder?.stop()
        cleanupAudioFile()
        
        // Deactivate audio session
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// MARK: - AVAudioRecorderDelegate
extension KeyboardViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording finished unsuccessfully")
            updateStatus("Recording failed")
            resetToIdleState()
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio recorder encode error: \(error?.localizedDescription ?? "Unknown error")")
        updateStatus("Recording error")
        resetToIdleState()
    }
}