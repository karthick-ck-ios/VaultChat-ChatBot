//
//  VaultChatModifier.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//


import SwiftUI

public struct VaultChatModifier: ViewModifier {

    @ObservedObject private var manager = VaultChatManager.shared

    public func body(content: Content) -> some View {
        ZStack {
            content

            if manager.configuration != nil {
                FloatingChatButton()
            }
        }
        .fullScreenCover(isPresented: $manager.showChat) {
            ChatScreen()
        }
    }
}

public extension View {
    func vaultChat() -> some View {
        modifier(VaultChatModifier())
    }
}
