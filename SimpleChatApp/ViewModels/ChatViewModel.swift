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
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        db.collection("chats").document(chatId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }

            guard let data = documentSnapshot?.data(),
                  let participants = data["participants"] as? [String],
                  participants.contains(userId),
                  let messagesData = data["messages"] as? [[String: Any]] else {
                self.errorMessage = "Access denied or invalid data"
                return
            }

            self.messages = messagesData.compactMap { messageDict -> Message? in
                guard let senderId = messageDict["senderId"] as? String,
                      let text = messageDict["text"] as? String,
                      let timestamp = messageDict["timestamp"] as? Timestamp else {
                    return nil
                }

                return Message(
                    id: UUID().uuidString,
                    text: text,
                    senderId: senderId,
                    timestamp: timestamp.dateValue()
                )
            }
        }
    }

    func sendMessage(toChat chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        let newMessageData: [String: Any] = [
            "senderId": userId,
            "text": self.newMessage,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("chats").document(chatId).updateData([
            "messages": FieldValue.arrayUnion([newMessageData])
        ]) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.newMessage = ""
            }
        }
    }
}
