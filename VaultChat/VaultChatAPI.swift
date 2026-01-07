//
//  VaultChatAPI.swift
//  vaultchat
//
//  Created by Karthi CK on 06/01/2026.
//

import Foundation

final class VaultChatAPI {

    static func sendMessage(
        _ message: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let config = VaultChatManager.shared.configuration,
              let url = URL(string: "https://api.vaultchat.io/askChatbot")
        else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create the body dictionary
        let body: [String: Any] = [
            "command": "askChatbot",
            "api_key": "\(config.apiKey)",
            "question": message  // using your `message` variable
        ]

        // Convert dictionary to JSON data
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let response = try? JSONDecoder().decode(ChatResponse.self, from: data)
            else {
                completion(.failure(NSError(domain: "Invalid response", code: -1)))
                return
            }

            if response.status == "SUCCESS" {
                // Success path
                completion(.success(response.data?.blocks?.first?.text ?? ""))
            } else {
                // Error path
                let errorMessage = response.statusMessage ?? "Unknown API error"
                completion(.failure(NSError(domain: errorMessage, code: -1)))
            }
        }
        .resume()

//        URLSession.shared.dataTask(with: request) { data, _, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            guard let data = data,
//                  let response = try? JSONDecoder().decode(ChatResponse.self, from: data)
//            else {
//                completion(.failure(NSError(domain: "Invalid response", code: -1)))
//                return
//            }
//
//            completion(.success(response.reply))
//        }
//        .resume()
    }
}

struct ChatRequest: Codable {
    let message: String
}

// MARK: - ChatResponse
struct ChatResponse: Codable {
    let status: String?              // "SUCCESS" or "ERROR"
    let statusMessage: String?       // "Invalid API Credentials", etc.
    let conversationID: String?
    let data: ChatData?
    let sources: [ChatSource]?
    
    enum CodingKeys: String, CodingKey {
        case status
        case statusMessage = "status_message"
        case conversationID = "conversation_id"
        case data
        case sources
    }
}

struct ChatData: Codable {
    let blocks: [ChatBlock]?
    let suggestions: [String]?
}

struct ChatBlock: Codable {
    let type: String?
    let text: String?
}

struct ChatSource: Codable {
    let documentKey: String?
    let documentID: String?
    let page: Int?
    let chunkIndex: Int?
    let distance: Double?
    
    enum CodingKeys: String, CodingKey {
        case documentKey = "document_key"
        case documentID = "document_id"
        case page
        case chunkIndex = "chunk_index"
        case distance
    }
}
