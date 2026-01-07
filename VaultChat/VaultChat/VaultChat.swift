//
//  vaultchat.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import Foundation
import SwiftUI

public enum VaultChat {

    public static func initialize(
        apiKey: String,
        primaryColorHex: String,
        theme: VaultChatTheme = .system,
        buttonContent: String = "💬",
        buttonType: ButtonType = .text,
        buttonShape: ButtonShape = .circle
    ) {
        let config = VaultChatConfiguration(
            apiKey: apiKey,
            primaryColor: Color(hex: primaryColorHex),
            theme: theme,
            buttonContent: buttonContent,
            buttonType: buttonType,
            buttonShape: buttonShape
        )

        VaultChatManager.shared.configure(config)
    }

    public static func open() {
        VaultChatManager.shared.openChat()
    }

    public static func close() {
        VaultChatManager.shared.closeChat()
    }
}
