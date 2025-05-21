//
//  GroupChatViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class GroupChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = true  // ✅ New flag

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    func fetchMessages(for groupId: String) {
        isLoading = true
        listener = db.collection("groups")
            .document(groupId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Fetch failed: \(error)")
                    self.isLoading = false
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.isLoading = false
                    return
                }

                self.messages = documents.compactMap {
                    try? $0.data(as: Message.self)
                }

                self.isLoading = false
            }
    }

    func sendMessage(_ text: String, groupId: String, senderId: String) {
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
        } catch {
            print("❌ Error sending text message: \(error)")
        }
    }

    func sendImage(_ image: UIImage, to groupId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user.")
            return
        }

        print("📸 Group image selected, uploading...")

        let imageId = UUID().uuidString
        let ref = Storage.storage().reference().child("groupImages/\(groupId)/\(imageId).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("❌ JPEG conversion failed.")
            return
        }

        let uploadTask = ref.putData(imageData, metadata: nil)

        uploadTask.observe(.success) { _ in
            print("✅ Uploaded to groupImages/\(groupId)/\(imageId).jpg")
            ref.downloadURL { url, error in
                guard let url = url else {
                    print("❌ No download URL.")
                    return
                }

                self.saveImageMessage(imageUrl: url.absoluteString, to: groupId, userId: userId)
            }
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                print("❌ Upload failed: \(error.localizedDescription)")
            }
        }
    }

    private func saveImageMessage(imageUrl: String, to groupId: String, userId: String) {
        let message = Message(
            id: UUID().uuidString,
            text: "",
            senderId: userId,
            timestamp: Date(),
            imageUrl: imageUrl,
            groupId: groupId
        )

        do {
            try Firestore.firestore()
                .collection("groups")
                .document(groupId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
            print("✅ Group image message saved to Firestore.")
        } catch {
            print("❌ Firestore save failed: \(error.localizedDescription)")
        }
    }


    func detachListener() {
        listener?.remove()
    }
}
