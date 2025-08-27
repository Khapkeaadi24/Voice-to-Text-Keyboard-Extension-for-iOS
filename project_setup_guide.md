# 🚀 Complete Setup Guide - Voice Keyboard iOS

## 🔧 Step-by-Step Xcode Setup

### Step 1: Create New Xcode Project

1. **Open Xcode** and create new project
2. **Choose Template**: iOS → App  
3. **Project Details**:
   - Product Name: `VoiceKeyboard`
   - Bundle Identifier: `com.yourname.voicekeyboard` (use your unique identifier)
   - Language: Swift
   - Interface: Storyboard
   - Use Core Data: ❌ (unchecked)
   - Include Tests: ❌ (unchecked)
4. **Update Info.plist** with provided configuration

### Step 4: Remove Storyboard References

1. **Open Info.plist** in source code view
2. **Delete these keys** if they exist:
   ```xml
   <key>UISceneStoryboardFile</key>
   <string>Main</string>
   <key>UIMainStoryboardFile</key>
   <string>Main</string>
   ```

### Step 5: Add Keyboard Extension Target

1. **Add Target**: File → New → Target
2. **Choose Template**: iOS → Custom Keyboard Extension
3. **Extension Details**:
   - Product Name: `VoiceKeyboardExtension`
   - Bundle Identifier: `com.yourname.voicekeyboard.keyboard`
   - Language: Swift
4. **Activate Scheme**: Click "Activate" when prompted
5. **Replace KeyboardViewController.swift** with provided code
6. **Update Info.plist** with provided configuration

### Step 6: Configure Bundle Identifiers

1. **Select Project** in navigator
2. **Main App Target**:
   - Bundle Identifier: `com.yourname.voicekeyboard`
   - Deployment Target: iOS 13.0
3. **Keyboard Extension Target**:
   - Bundle Identifier: `com.yourname.voicekeyboard.keyboard` 
   - Deployment Target: iOS 13.0

### Step 7: Set Development Team

1. **Select Project** → Targets
2. **For both targets**:
   - Go to "Signing & Capabilities"
   - Select your Development Team
   - Ensure "Automatically manage signing" is checked

### Step 8: Add API Key

1. **Open** `VoiceKeyboardExtension/KeyboardViewController.swift`
2. **Find line ~249**: `let apiKey = "YOUR_GROQ_API_KEY_HERE"`
3. **Replace** with your Groq API key:
   ```swift
   let apiKey = "gsk_your_actual_groq_api_key_here"
   ```

## 🔑 Get Your Groq API Key

1. **Visit**: [console.groq.com](https://console.groq.com/)
2. **Sign up** or log in
3. **Navigate** to API Keys section
4. **Create** new API key
5. **Copy** the key (starts with `gsk_`)

## ✅ Build and Test

### Build Process

1. **Clean Build**: Product → Clean Build Folder (⌘+Shift+K)
2. **Select Main App** scheme
3. **Build**: Product → Build (⌘+B)
4. **Run**: Product → Run (⌘+R)

### Install on Device

1. **Connect** your iPhone/iPad
2. **Select** your device as destination
3. **Build and Run** the main app
4. **Trust** developer if prompted in Settings

### Enable Keyboard

1. **Open Settings** on device
2. **Go to**: General → Keyboard → Keyboards
3. **Tap**: "Add New Keyboard..."
4. **Select**: "Voice Keyboard" (under Third-Party Keyboards)
5. **⚠️ CRITICAL**: Tap "Voice Keyboard" again → Enable "Allow Full Access"

## 🧪 Testing

### Quick Test

1. **Open any app** with text input (Messages, Notes, etc.)
2. **Tap** in text field
3. **Switch keyboard**: Tap globe icon (🌐) until you see Voice Keyboard
4. **Test recording**: Press and hold microphone button
5. **Speak**: "Hello world"  
6. **Release**: Button and wait for transcription

### Test Checklist

- ✅ Keyboard appears when switching
- ✅ Button responds to press and hold
- ✅ Recording indicator shows (red button, pulsing)
- ✅ Status messages update correctly
- ✅ API call completes (activity indicator)
- ✅ Text appears in input field
- ✅ Microphone permission granted
- ✅ Network connectivity working

## 🛠️ Common Build Issues

### Issue: "No such module 'AVFoundation'"
**Solution**: AVFoundation is system framework, no import needed. Check spelling.

### Issue: "Bundle identifier already in use"
**Solution**: Change bundle identifiers to be unique:
```
com.yourname.voicekeyboard
com.yourname.voicekeyboard.keyboard
```

### Issue: "Code signing error"
**Solution**: 
1. Select valid development team
2. Ensure device is registered
3. Check provisioning profiles

### Issue: "Keyboard extension crashes"
**Solution**:
1. Check console logs in Xcode
2. Verify API key is valid
3. Test on physical device (not simulator)

## 📱 Deployment Considerations

### For TestFlight/App Store

1. **Update Bundle IDs** to match your developer account
2. **Store API Key Securely** (use Keychain in production)
3. **Add App Icons** (required for App Store)
4. **Test thoroughly** on multiple devices
5. **Follow App Review Guidelines** for keyboard extensions

### Security Best Practices

```swift
// For production, use Keychain instead of hardcoded API key
import Security

class APIKeyManager {
    static func getAPIKey() -> String? {
        // Implement Keychain storage
        return getFromKeychain("groq_api_key")
    }
}
```

## 📊 Performance Tips

### Optimize for Extension Limits

1. **Memory**: Keep under 30MB
2. **CPU**: Minimize heavy processing
3. **Network**: Cache API responses if possible
4. **Battery**: Optimize audio recording settings

### Audio Settings Explained

```swift
let settings: [String: Any] = [
    AVFormatIDKey: kAudioFormatLinearPCM,  // Uncompressed for quality
    AVSampleRateKey: 16000.0,              // 16kHz optimal for Whisper
    AVNumberOfChannelsKey: 1,              // Mono saves bandwidth
    AVLinearPCMBitDepthKey: 16,            // 16-bit good quality/size ratio
    AVLinearPCMIsFloatKey: false,          // Integer samples
    AVLinearPCMIsBigEndianKey: false       // Little endian
]
```

## 🔧 Customization Options

### Change Colors

```swift
// In KeyboardViewController.swift
recordButton.backgroundColor = .systemPurple  // Your brand color
statusLabel.textColor = .systemOrange         // Status text color
```

### Modify Button Text

```swift
recordButton.setTitle("🎵 Tap to Sing", for: .normal)  // Custom text
```

### Adjust Timing

```swift
longPress.minimumPressDuration = 0.2  // Longer press required
request.timeoutInterval = 45.0        // Longer API timeout
```

## 📞 Support & Resources

### Documentation Links
- [Apple Keyboard Extensions](https://developer.apple.com/documentation/uikit/keyboards_and_input)
- [Groq API Docs](https://console.groq.com/docs)
- [AVAudioRecorder Reference](https://developer.apple.com/documentation/avfaudio/avaudiorecorder)

### Community Resources
- [iOS Dev Community](https://iosdev.space/)
- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow - iOS](https://stackoverflow.com/questions/tagged/ios)

### Troubleshooting Logs

Enable detailed logging:
```swift
// Add to KeyboardViewController
override func viewDidLoad() {
    super.viewDidLoad()
    print("🎤 Voice Keyboard Extension Loaded")
    // ... rest of setup
}
```

## 🎯 Next Steps

Once basic setup works:

1. **Add waveform visualization** during recording
2. **Implement offline queueing** for poor network
3. **Add multi-language support** 
4. **Create custom themes**
5. **Add unit tests**
6. **Optimize for iPad**

---

**🎉 You're all set! Your voice keyboard should now be working perfectly.**

Need help? Check the main README.md or create an issue on GitHub!. **Choose Location** and click "Create"

### Step 2: Clean Up Default Files

1. **Delete these files**:
   - `ViewController.swift` (delete)
   - `Main.storyboard` (delete)
2. **Keep these files**:
   - `AppDelegate.swift` (replace content)
   - `SceneDelegate.swift` (may need to create)
   - `Info.plist` (update content)

### Step 3: Add Your Files

1. **Replace AppDelegate.swift** with provided code
2. **Create SceneDelegate.swift** (if not exists) with provided code  
3. **Create MainViewController.swift** with provided code
4