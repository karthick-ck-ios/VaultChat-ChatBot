//
//  ChatInputView.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import SwiftUI

//struct ChatInputView: View {
//
//    @ObservedObject private var manager = VaultChatManager.shared
//
//    @ObservedObject var viewModel: ChatViewModel
//
//    var body: some View {
//        HStack {
//            TextField("Type a message", text: $viewModel.inputText)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .disabled(viewModel.isLoading)
//                .frame(height: 50)
//
//            Button {
//                viewModel.send()
//            } label: {
//                if viewModel.isLoading {
//                    ProgressView()
//                } else {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(manager.configuration?.primaryColor)
//                }
//            }
//            .disabled(viewModel.isLoading)
//        }
//        .padding()
//    }
//}

struct ChatInputView: View {

    @ObservedObject private var manager = VaultChatManager.shared
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        HStack {
            TextField("Type a message...", text: $viewModel.inputText)
                .padding(.horizontal, 16)
                .frame(height: 55)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color(.systemBackground))
                        )
                )
                .disabled(viewModel.isLoading)

            Button {
                viewModel.send()
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            // 🔥 gray when empty
                            viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.gray.opacity(0.2)
                            : (manager.configuration?.primaryColor.opacity(0.2) ?? Color.gray.opacity(0.2))
                        )
                        .frame(width: 50, height: 50)

                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: manager.configuration?.primaryColor ?? .blue
                                )
                            )
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(
                                // 🔥 gray when empty
                                viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.gray
                                : (manager.configuration?.primaryColor ?? .blue)
                            )
                    }
                }
            }
            // 🔒 disable button when empty OR loading
            .disabled(
                viewModel.isLoading ||
                viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}


//struct ChatInputView: View {
//
//    @ObservedObject private var manager = VaultChatManager.shared
//    @ObservedObject var viewModel: ChatViewModel
//
//    var body: some View {
//        HStack {
//            TextField("Type a message...", text: $viewModel.inputText)
//                .padding(.horizontal, 16) // padding inside the field
//                .frame(height: 55)         // increased height
//                .background(
//                    RoundedRectangle(cornerRadius: 30) // semicircle for 55 height
//                        .strokeBorder(Color.gray.opacity(0.5), lineWidth: 1)
//                        .background(
//                            RoundedRectangle(cornerRadius: 30)
//                                .fill(Color(.systemBackground))
//                        )
//                )
//                .disabled(viewModel.isLoading)
//
//            Button {
//                viewModel.send()
//            } label: {
//                ZStack {
//                    Circle()
//                        .fill(manager.configuration?.primaryColor.opacity(0.2) ?? Color.gray.opacity(0.2))
//                        .frame(width: 50, height: 50)
//
//                    if viewModel.isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: manager.configuration?.primaryColor ?? .blue))
//                            .frame(width: 24, height: 24)
//                    } else {
//                        Image(systemName: "paperplane.fill")
//                            .foregroundColor(manager.configuration?.primaryColor)
//                    }
//                }
//            }
//            .disabled(viewModel.isLoading)
//        }
//        .padding(.horizontal)
//        .padding(.vertical, 8)
//    }
//}
