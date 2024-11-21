//
//  InboxViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class InboxViewModel: ObservableObject {
    @Published var users: [User] = [] // Users list
    @Published var isLoading: Bool = false // Loading state
    @Published var errorMessage: String? // Error message

    private let db = Firestore.firestore() // Firestore reference

    // Fetch users from Firestore
    func fetchUsers() {
        isLoading = true
        db.collection("users").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                    return
                }

                self.users = snapshot?.documents.compactMap { document in
                    let data = document.data()

                    // Ensure required fields are valid
                    guard let name = data["name"] as? String,
                          let email = data["email"] as? String else {
                        print("Invalid or missing required fields for user \(document.documentID)")
                        return nil
                    }

                    // Optional profile picture
                    let profilePictureURL = data["profilePictureURL"] as? String

                    // Return a valid User object
                    return User(id: document.documentID, name: name, email: email, profilePictureURL: profilePictureURL)
                } ?? []
            }
        }
    }
}
