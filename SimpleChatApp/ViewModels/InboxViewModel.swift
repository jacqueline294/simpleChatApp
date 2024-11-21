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
    
    private let db = Firestore.firestore() // Firestore reference
    
    // Fetch users from Firestore
    func fetchUsers() {
        isLoading = true
        errorMessage = nil
        
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async { // Correctly opening the closure
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                    print("Firestore error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No data found in users collection."
                    print("No documents found in Firestore collection.")
                    return
                }
                
                // Safely parse documents into users
                self.users = documents.compactMap { document -> User? in
                    let data = document.data()
                    guard let name = data["name"] as? String,
                          let email = data["email"] as? String else {
                        print("Invalid or missing required fields for user \(document.documentID)")
                        return nil
                    }
                    
                    return User(
                        id: document.documentID,
                        name: name,
                        email: email,
                        password: "",
                        profilePictureURL: data["profilePictureURL"] as? String
                    )
                }
                
                // Debugging output
                print("Successfully fetched \(self.users.count) users.")
            } // Make sure this ends the async block
        }
    }
}
