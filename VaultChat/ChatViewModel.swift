//
//  ChatViewModel.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import SwiftUI
import Combine

public final class ChatViewModel: ObservableObject {

    @Published public var messages: [ChatMessage] = []
    @Published public var inputText: String = ""
    @Published public var isLoading: Bool = false

    public init() {}

    public func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        inputText = ""
        messages.append(ChatMessage(text: text, isUser: true))
        isLoading = true

        VaultChatAPI.sendMessage(text) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let reply):
                    self?.messages.append(ChatMessage(text: reply, isUser: false))
                case .failure:
                    self?.messages.append(
                        ChatMessage(
                            text: "Something went wrong. Please try again.",
                            isUser: false
                        )
                    )
                }
            }
        }
    }
}
