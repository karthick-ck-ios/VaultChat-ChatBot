# VaultChat
Intelligent Document Chat for Your Business

VaultChat iOS SDK

VaultChat is a lightweight iOS framework that provides an in-app floating chat assistant button that can be customized in appearance and behavior. It supports UIKit and SwiftUI applications.

📦 Installation (CocoaPods)

Add VaultChat to your Podfile:

    pod 'VaultChat', :git => 'https://github.com/karthick-ck-ios/VaultChat.git'

Then install:

    pod install
    
Open the generated .xcworkspace file.

✅ Requirements

iOS 15.0+
Swift 5+

🚀 Initialization

Before using VaultChat, initialize it once at app launch or view creation.

🔹 Parameters
Parameter	    Description
apiKey	        Your VaultChat API key
primaryColor    Hex	Primary theme color in HEX
theme	        .light, .dark, .system
buttonContent	SF Symbol or text
buttonType	    .image or .text
buttonShape	    .circle, .square, etc.

🧭 Usage in UIKit
Call initialization inside viewDidLoad, then add the floating button.

    VaultChat.initialize(
        apiKey: "API-KEY",
        primaryColorHex: "#007AFF",
        theme: .system,
        buttonContent: "pencil.circle.fill",
        buttonType: .image,
        buttonShape: .square
    )
    self.addVaultChatFloatingButton()


🟣 Usage in SwiftUI

Initialize inside the view init().

    init() {
    VaultChat.initialize(
        apiKey: "API-KEY",
        primaryColorHex: "#2663EB",
        theme: .system,
        buttonContent: "message.fill",
        buttonType: .image,
        buttonShape: .square
    )
    }

🎨 Customization Options
Floating button size
Shape: circle or square
Icon or text
System/light/dark theme
Accent color

🛠 Troubleshooting
1. Make sure you opened the .xcworkspace
2. Clean build folder if needed
3. Ensure correct API key
4. Verify SF Symbols name is valid
