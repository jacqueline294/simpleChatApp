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
            // Removed type: .text
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
            text: "", // Image messages might not have text, or could have a caption
            senderId: userId,
            timestamp: Date(),
            imageUrl: imageUrl,
            groupId: chatId
            // Removed type: .image
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
    
    
    // Send File Message
    func sendFile(fileURL: URL, originalFileName: String, toChat chatId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user. Cannot send file.")
            // Ensure the temporary file is no longer accessed if we bail early
            fileURL.stopAccessingSecurityScopedResource()
            return
        }
        
        print("📄 Preparing to send file: \(originalFileName) from URL: \(fileURL.path) to chat: \(chatId)")
        
        let fileExtension = fileURL.pathExtension
        let uniqueFileNameForStorage = "\(UUID().uuidString).\(fileExtension)"
        let storageRef = Storage.storage().reference().child("chatFiles/\(chatId)/\(uniqueFileNameForStorage)")
        
        // Start accessing the security-scoped resource.
        // The URL from document picker needs this.
        guard fileURL.startAccessingSecurityScopedResource() else {
            print("❌ Could not access security-scoped resource for file at \(fileURL.path)")
            return
        }
        
        // Upload the file
        storageRef.putFile(from: fileURL, metadata: nil) { metadata, error in
            // Stop accessing the security-scoped resource as soon as the upload is done or fails.
            fileURL.stopAccessingSecurityScopedResource()
            
            if let error = error {
                print("❌ Failed to upload file to Firebase Storage: \(error.localizedDescription)")
                return
            }
            
            print("✅ File uploaded successfully: \(uniqueFileNameForStorage)")
            
            // Get the download URL
            storageRef.downloadURL { [weak self] (url, error) in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Failed to get download URL: \(error.localizedDescription)")
                    return
                }
                
                guard let downloadURL = url else {
                    print("❌ Download URL was nil.")
                    return
                }
                
                print("✅ Download URL obtained: \(downloadURL.absoluteString)")
                
                // Create message object
                let message = Message(
                    id: UUID().uuidString,
                    text: originalFileName, // Store original file name in 'text'
                    senderId: userId,
                    timestamp: Date(),
                    imageUrl: downloadURL.absoluteString, // Use 'imageUrl' to store the file's download URL
                    groupId: chatId
                    // Removed type: .file
                )
                
                // Save message to Firestore
                do {
                    try self.db.collection("chats")
                        .document(chatId)
                        .collection("messages")
                        .document(message.id)
                        .setData(from: message)
                    print("✅ File message saved to Firestore.")
                } catch {
                    print("❌ Failed to send file message to Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
}
