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
    @Published var users: [User] = []
    @Published var groups: [Group] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedChatId: String?

    private let db = Firestore.firestore()

    // Fetch Users
    func fetchUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to get current user."
            return
        }

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

                    let profileImageURL = data["profileImageURL"] as? String
                    return User(id: id, name: name, email: email, profileImageURL: profileImageURL)
                } ?? []
            }
        }
    }

    //  - Create or Get Chat ID
    func getOrCreateChatId(with userId: String, completion: @escaping (String?) -> Void) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to get current user."
            completion(nil)
            return
        }

        let chatsRef = db.collection("chats")
        chatsRef
            .whereField("participants", arrayContains: currentUserId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    self?.errorMessage = "Failed to fetch chats: \(error.localizedDescription)"
                    completion(nil)
                    return
                }

                if let document = snapshot?.documents.first(where: {
                    let participants = $0.data()["participants"] as? [String] ?? []
                    return participants.contains(userId)
                }) {
                    completion(document.documentID)
                } else {
                    let newChatRef = chatsRef.document()
                    let chatData: [String: Any] = [
                        "participants": [currentUserId, userId],
                        "created": Timestamp(date: Date())
                    ]
                    newChatRef.setData(chatData) { error in
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

    //  Fetch Groups
    func fetchGroups() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("groups").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("❌ Error fetching groups: \(error)")
                return
            }

            self?.groups = snapshot?.documents.compactMap {
                try? $0.data(as: Group.self)
            }.filter {
                $0.members.contains(userId)
            } ?? []
        }
    }

    //  Delete Group
    func deleteGroup(_ group: Group) {
        db.collection("groups").document(group.id).delete { error in
            if let error = error {
                print("❌ Failed to delete group: \(error)")
            } else {
                print("✅ Group deleted")
                self.fetchGroups()
            }
        }
    }
}
