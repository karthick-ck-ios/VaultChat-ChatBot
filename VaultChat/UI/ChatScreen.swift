//
//  ChatScreen.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//


import SwiftUI

public struct ChatScreen: View {

    @ObservedObject private var manager = VaultChatManager.shared
    @StateObject private var viewModel = ChatViewModel()

    public var body: some View {
        NavigationView {
            VStack {
                Divider()
                    .background(manager.configuration?.primaryColor.opacity(0.3))
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(manager.configuration?.primaryColor ?? .blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(12)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }

                Divider()
                ChatInputView(viewModel: viewModel)
            }
            .navigationTitle(manager.configuration?.chatTitle ?? "Powered by VaultChat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    manager.closeChat()
                }) {
                    Image(systemName: "xmark") // SF Symbol for "X"
//                        .foregroundColor(.primary) // adjust color if needed
                        .imageScale(.small)        // optional size
                }
            )

        }
    }
}
