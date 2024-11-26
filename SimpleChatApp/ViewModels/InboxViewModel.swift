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

    private let db = Firestore.firestore()

    func fetchUsers() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "Failed to get current user."
            return
        }
        print("Fetching user from firestore...")

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

    func preloadMockUsers() {
        self.users = [
            User(id: "1", name: "Alice", email: "alice@example.com", profileImageURL: nil),
            User(id: "2", name: "Bob", email: "bob@example.com", profileImageURL: nil),
            User(id: "3", name: "Charlie", email: "charlie@example.com", profileImageURL: nil)
        ]
    }
}
