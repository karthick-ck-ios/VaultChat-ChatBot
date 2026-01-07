//
//  FloatingChatButton.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

//import SwiftUI

//public struct FloatingChatButton: View {
//
//    @ObservedObject private var manager = VaultChatManager.shared
//    @State private var showAlert = false
//
//    public var body: some View {
//        if let config = manager.configuration {
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button {
//                        // Check if API key is empty
//                        if config.apiKey.isEmpty {
//                            showAlert = true
//                        } else {
//                            manager.openChat()
//                        }
//                    } label: {
//                        Image(systemName: "message.fill")
//                            .foregroundColor(.white)
//                            .frame(
//                                width: config.floatingButtonSize,
//                                height: config.floatingButtonSize
//                            )
//                            .background(config.primaryColor)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                    .padding(.trailing, config.trailingPadding)
//                    .padding(.bottom, config.bottomPadding)
//                    // Attach alert
//                    .alert("Configuration Error", isPresented: $showAlert) {
//                        Button("OK", role: .cancel) {}
//                    } message: {
//                        Text("The API key is invalid. Please enter a valid API key to continue.")
//                    }
//
//                }
//            }
//        }
//    }
//}

import SwiftUI

public struct FloatingChatButton: View {

    @ObservedObject private var manager = VaultChatManager.shared
    @State private var showAlert = false

    public var body: some View {
        if let config = manager.configuration {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        if config.apiKey.isEmpty {
                            showAlert = true
                        } else {
                            manager.openChat()
                        }
                    } label: {
                        // CONTENT BASED ON TYPE
                        Group {
                            switch config.buttonType {
                            case .text:
                                Text(config.buttonContent)

                            case .image:
                                // assumes SF Symbol name or asset name
                                Image(systemName: config.buttonContent)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(12)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(
                            width: config.floatingButtonSize,
                            height: config.floatingButtonSize
                        )
                        .background(config.primaryColor)
                        .modifier(ButtonShapeModifier(shape: config.buttonShape))
                        .shadow(radius: 4)
                    }
                    .padding(.trailing, config.trailingPadding)
                    .padding(.bottom, config.bottomPadding)
                    .alert("Configuration Error", isPresented: $showAlert) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text("The API key is invalid. Please enter a valid API key to continue.")
                    }
                }
            }
        }
    }
}

private struct ButtonShapeModifier: ViewModifier {

    let shape: ButtonShape

    func body(content: Content) -> some View {
        switch shape {
        case .circle:
            content.clipShape(Circle())

        case .square:
            content.clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
