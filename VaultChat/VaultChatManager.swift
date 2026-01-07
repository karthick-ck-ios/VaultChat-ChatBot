//
//  VaultChatManager.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//


import SwiftUI
import Combine

public final class VaultChatManager: ObservableObject {

    public static let shared = VaultChatManager()

    @Published public var showChat: Bool = false
    public private(set) var configuration: VaultChatConfiguration?

    private init() {}

    public func configure(_ config: VaultChatConfiguration) {
        self.configuration = config
        applyTheme(config.theme)
    }

    public func openChat() {
        showChat = true
    }

    public func closeChat() {
        showChat = false
    }

    private func applyTheme(_ theme: VaultChatTheme) {
        DispatchQueue.main.async {
            switch theme {
            case .light:
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .light
            case .dark:
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .dark
            case .system:
                UIApplication.shared.windows.first?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
}
