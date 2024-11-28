//
//  InboxViewModel.swift
//  SimpleChatApp
//
//  Created by Jacqueline Ngigi on 2024-11-21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class InboxViewModel: ObservableObject {
    @Published var users: [User] = [] // List of users
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedChatId: String? // The selected chat ID for navigation purposes

    private let db = Firestore.firestore()

    // Fetch all users except the current user
    func fetchUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to get current user."
            return
        }
        print("Fetching users from Firestore...")

        isLoading = true
        db.collection("users").getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                    return
                }

                self?.users = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    guard let id = document.documentID as String?,
                          let name = data["name"] as? String,
                          let email = data["email"] as? String,
                          id != currentUserId else {
                        return nil
                    }
                    
                    // Retrieve optional profileImageURL
                    let profileImageURL = data["profileImageURL"] as? String

                    return User(id: id, name: name, email: email, profileImageURL: profileImageURL)
                } ?? []
            }
        }
    }

    // Create or fetch an existing chat ID for the current user and the selected user
    func getOrCreateChatId(with userId: String, completion: @escaping (String?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to get current user."
            completion(nil)
            return
        }

        let chatsRef = db.collection("chats")
        
        // Query for chats that include both users
        chatsRef
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "Failed to fetch chats: \(error.localizedDescription)"
                    completion(nil)
                    return
                }

                // Check if there's an existing chat that includes both users
                if let document = snapshot?.documents.first(where: {
                    let participants = $0.data()["participants"] as? [String] ?? []
                    return participants.contains(userId)
                }) {
                    // Chat already exists, return its ID
                    completion(document.documentID)
                } else {
                    // Chat doesn't exist, create a new one
                    let newChatRef = chatsRef.document()
                    let chatData: [String: Any] = [
                        "participants": [currentUserId, userId],
                        "created": Timestamp(date: Date())
                    ]
                    newChatRef.setData(chatData) { [weak self] error in
                        if let error = error {
                            self?.errorMessage = "Failed to create chat: \(error.localizedDescription)"
                            completion(nil)
                        } else {
                            completion(newChatRef.documentID)
                        }
                    }
                }
            }
    }
}
