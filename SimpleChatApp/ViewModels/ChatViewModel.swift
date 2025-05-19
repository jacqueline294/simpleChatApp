//
//  MessagesViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-18.
//

import FirebaseFirestore
import FirebaseAuth

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var newMessage: String = ""
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    // Fetch messages for the specific chat room using the chatId
    func fetchMessages(forChat chatId: String) {
        // Access the messages subcollection under the specific chat document
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "No messages found"
                    return
                }

                // Map documents to Message objects
                self.messages = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Message.self)
                }
            }
    }

    // Send a new message to the specific chat room using the chatId
    func sendMessage(toChat chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        let newMessage = Message(
            id: UUID().uuidString,
            text: self.newMessage,
            senderId: userId,
            timestamp: Date(),
            imageUrl: nil,
            groupId: chatId // ✅ REQUIRED
        )

        do {
            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(newMessage.id)
                .setData(from: newMessage)

            self.newMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

}
