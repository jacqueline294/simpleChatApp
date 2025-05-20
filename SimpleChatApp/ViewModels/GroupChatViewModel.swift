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

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    func fetchMessages(for groupId: String) {
        listener = db.collection("groups")
            .document(groupId)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Fetch failed: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap {
                    try? $0.data(as: Message.self)
                }
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

        // ✅ Step 1: Ensure group document exists
        let groupRef = db.collection("groups").document(groupId)
        groupRef.setData(["createdAt": FieldValue.serverTimestamp()], merge: true)

        // ✅ Step 2: Prepare image
        let imageId = UUID().uuidString
        let ref = Storage.storage().reference().child("groupImages/\(groupId)/\(imageId).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            print("❌ Failed to convert image to JPEG.")
            return
        }

        print("📤 Uploading image to groupImages/\(groupId)/\(imageId).jpg")

        // ✅ Step 3: Upload image
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("❌ Upload failed: \(error.localizedDescription)")
                return
            }

            // ✅ Step 4: Get download URL
            ref.downloadURL { url, error in
                if let error = error {
                    print("❌ Failed to get download URL: \(error.localizedDescription)")
                    return
                }

                guard let url = url else {
                    print("❌ Download URL is nil")
                    return
                }

                print("✅ Got image URL: \(url.absoluteString)")

                // ✅ Step 5: Save image message to Firestore
                let message = Message(
                    id: UUID().uuidString,
                    text: "",
                    senderId: userId,
                    timestamp: Date(),
                    imageUrl: url.absoluteString,
                    groupId: groupId
                )

                do {
                    try self.db.collection("groups")
                        .document(groupId)
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

    


    func detachListener() {
        listener?.remove()
    }
}
