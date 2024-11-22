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
    @Published var users: [User] = [] // Users list
    @Published var isLoading: Bool = false // Loading state
    @Published var errorMessage: String? // Error message
    
    private let db = Firestore.firestore()

    func fetchUsers() {
        isLoading = true
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            self.isLoading = false

            if let error = error {
                self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                print("Error fetching users: \(error.localizedDescription)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                self.errorMessage = "No users found"
                print("No documents found")
                return
            }

            self.users = documents.compactMap { queryDocumentSnapshot -> User? in
                let data = queryDocumentSnapshot.data()
                guard let name = data["username"] as? String,
                      let email = data["email"] as? String else {
                    print("Missing required fields for document: \(queryDocumentSnapshot.documentID)")
                    return nil
                }

                return User(id: queryDocumentSnapshot.documentID, name: name, email: email, firebaseUser: Auth.auth().currentUser!)
            }
        }
    }
}
