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

    func fetchMessages(forChat chatId: String) {
        db.collection("messages")
            .whereField("chatId", isEqualTo: chatId)
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

                self.messages = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Message.self)
                }
            }
    }

    func sendMessage(toChat chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        let newMessage = Message(
            id: UUID().uuidString,
            text: self.newMessage,
            senderId: userId,
            timestamp: Date()
        )

        do {
            try db.collection("messages").document(newMessage.id).setData(from: newMessage)
            self.newMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

