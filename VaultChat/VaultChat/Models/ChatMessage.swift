//
//  ChatMessage.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//


import Foundation

public struct ChatMessage: Identifiable {
    public let id = UUID()
    public let text: String
    public let isUser: Bool
}
