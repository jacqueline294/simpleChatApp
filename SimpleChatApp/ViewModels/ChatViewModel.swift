//
//  MessagesViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-18.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

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

        let trimmedText = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        let message = Message(
            id: UUID().uuidString,
            text: trimmedText,
            senderId: userId,
            timestamp: Date(),
            imageUrl: nil,
            groupId: chatId // reused as chatId
        )

        do {
            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            
            // Clear text after sending
            self.newMessage = ""
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func sendImage(_ image: UIImage, to chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user.")
            return
        }

        // ✅ Step 1: Ensure the parent chat document exists
        let chatRef = db.collection("chats").document(chatId)
        chatRef.setData(["createdAt": FieldValue.serverTimestamp()], merge: true)

        // ✅ Step 2: Prepare image
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference().child("chatImages/\(chatId)/\(imageId).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG.")
            return
        }

        print("📤 Uploading image for chat \(chatId)...")

        // ✅ Step 3: Upload to Firebase Storage
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("❌ Upload failed: \(error.localizedDescription)")
                return
            }

            ref.downloadURL { url, error in
                if let error = error {
                    print("❌ Failed to get download URL: \(error.localizedDescription)")
                    return
                }

                guard let url = url else {
                    print("❌ URL is nil.")
                    return
                }

                print("✅ Got image URL: \(url.absoluteString)")

                let message = Message(
                    id: UUID().uuidString,
                    text: "",
                    senderId: userId,
                    timestamp: Date(),
                    imageUrl: url.absoluteString,
                    groupId: chatId // reused as chatId
                )

                do {
                    try self.db.collection("chats")
                        .document(chatId)
                        .collection("messages")
                        .document(message.id)
                        .setData(from: message)

                    print("✅ Image message saved to Firestore.")
                } catch {
                    print("❌ Firestore save failed: \(error.localizedDescription)")
                }
            }
        }
    }


}
