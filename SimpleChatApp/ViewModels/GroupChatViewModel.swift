//
//  GroupChatViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


class GroupChatViewModel: ObservableObject {
    @Published var messages: [Message] = []

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// Currently authenticated user ID
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    /// Fetch messages for a specific group chat
    func fetchMessages(for groupId: String) {
        print("📡 Fetching messages for group: \(groupId)")

        listener = db.collection("groups")
            .document(groupId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Failed to fetch group messages: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found.")
                    return
                }

                self.messages = documents.compactMap {
                    try? $0.data(as: Message.self)
                }

                print("✅ Loaded \(self.messages.count) messages")
            }
    }

    /// Send a message to a specific group
    func sendMessage(_ text: String, groupId: String, senderId: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Empty message not sent")
            return
        }

        let message = Message(
            id: UUID().uuidString,
            text: text,
            senderId: senderId,
            timestamp: Date(),
            imageUrl: nil,
            groupId: groupId
        )

        do {
            try db.collection("groups")
                .document(groupId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            print("✅ Message sent: \(text)")
        } catch {
            print("❌ Error sending message: \(error)")
        }
    }

    func detachListener() {
        listener?.remove()
    }
}
