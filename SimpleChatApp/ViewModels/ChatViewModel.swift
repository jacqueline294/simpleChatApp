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
    
    private let db = Firestore.firestore()
    
    // Fetch Messages
    func fetchMessages(forChat chatId: String) {
        db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                self.messages = snapshot?.documents.compactMap {
                    try? $0.data(as: Message.self)
                } ?? []
            }
    }
    
    //  Send Text Message
    func sendMessage(toChat chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let trimmed = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let message = Message(
            id: UUID().uuidString,
            text: trimmed,
            senderId: userId,
            timestamp: Date(),
            imageUrl: nil,
            groupId: chatId // reuse groupId field for private chat
        )
        
        do {
            try db.collection("chats")
                .document(chatId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            newMessage = ""
        } catch {
            print("❌ Failed to send message: \(error.localizedDescription)")
        }
    }
    
    //  Send Image Message
    func sendImage(_ image: UIImage, to chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user.")
            return
        }
        
        print("📸 Image selected, preparing upload...")
        
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference().child("chatImages/\(chatId)/\(imageId).jpg")
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ Failed to convert image to JPEG.")
            return
        }
        
        let uploadTask = ref.putData(imageData, metadata: nil)
        
        uploadTask.observe(.success) { _ in
            print("✅ Image uploaded to chatImages/\(chatId)/\(imageId).jpg")
            ref.downloadURL { url, error in
                guard let url = url else {
                    print("❌ Failed to retrieve download URL.")
                    return
                }
                
                self.saveImageMessage(imageUrl: url.absoluteString, to: chatId, userId: userId)
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("❌ Upload error: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveImageMessage(imageUrl: String, to chatId: String, userId: String) {
        let message = Message(
            id: UUID().uuidString,
            text: "",
            senderId: userId,
            timestamp: Date(),
            imageUrl: imageUrl,
            groupId: chatId
        )
        
        do {
            try Firestore.firestore()
                .collection("chats")
                .document(chatId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            print("✅ Chat image message saved to Firestore.")
        } catch {
            print("❌ Firestore save error: \(error.localizedDescription)")
        }
    }
}
