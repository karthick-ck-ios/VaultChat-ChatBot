//
//  VaultChatConfiguration.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//


import SwiftUI

public struct VaultChatConfiguration {

    public let apiKey: String
    public let primaryColor: Color
    public let theme: VaultChatTheme

    // UI
    public let floatingButtonSize: CGFloat = 56
    public let bottomPadding: CGFloat = 24
    public let trailingPadding: CGFloat = 16
    public let chatTitle: String = "Powered by VaultChat"

    // New optional button properties (with defaults)
    public let buttonContent: String
    public let buttonType: ButtonType
    public let buttonShape: ButtonShape

    public init(
        apiKey: String,
        primaryColor: Color,
        theme: VaultChatTheme,
        buttonContent: String = "💬",
        buttonType: ButtonType = .text,
        buttonShape: ButtonShape = .circle
    ) {
        self.apiKey = apiKey
        self.primaryColor = primaryColor
        self.theme = theme
        self.buttonContent = buttonContent
        self.buttonType = buttonType
        self.buttonShape = buttonShape
    }
}

public enum ButtonType {
    case text
    case image
}

public enum ButtonShape {
    case circle
    case square
}
