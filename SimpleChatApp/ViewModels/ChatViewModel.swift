//
//  MessagesViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-18.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine




class ChatViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    @Published var errorMessage: String?
    
   
    private var db = Firestore.firestore()
    private var cancellables: Set<AnyCancellable> = []

    
    func fetchMessages(forChat chatId: String) {
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Error fetching messages: \(error.localizedDescription)"
                    }
                    return
                }

                guard let documents = snapshot?.documents else { return }

                DispatchQueue.main.async {
                    self?.messages = documents.compactMap { doc in
                        try? doc.data(as: Message.self)
                    }
                }
            }
    }

    
    func sendMessage(toChat chatId: String) {
        guard let currentUser = Auth.auth().currentUser else {
            self.errorMessage = "User not authenticated"
            return
        }

        guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        let message = Message(
            id: UUID().uuidString,
            content: newMessage,
            senderId: currentUser.uid,
            senderName: currentUser.displayName ?? "Unknown",
            timestamp: Date()
        )

        do {
            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(message.id!)
                .setData(from: message)

            DispatchQueue.main.async {
                self.newMessage = "" // Clear the message input field
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error sending message: \(error.localizedDescription)"
            }
        }
    }
}
