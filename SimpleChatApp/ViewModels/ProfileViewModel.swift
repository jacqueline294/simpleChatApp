//
//  ProfileViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    @Published var name: String = "Loading..."
    @Published var email: String = "Loading..."
    @Published var showingImagePicker = false
    @Published var isLoggedOut = false
    @Published var navigateToInbox = false
    @Published var alertItem: AlertItem? = nil

    func loadUserInfo() {
        guard let user = Auth.auth().currentUser else {
            alertItem = AlertItem(title: "Error", message: "User not logged in.")
            return
        }

        email = user.email ?? "No email"

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                self.alertItem = AlertItem(title: "Error", message: error.localizedDescription)
                return
            }

            if let data = snapshot?.data() {
                self.name = data["name"] as? String ?? "No name available"
            } else {
                self.alertItem = AlertItem(title: "Error", message: "Failed to fetch user information.")
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            isLoggedOut = true
        } catch {
            alertItem = AlertItem(title: "Error", message: "Failed to log out: \(error.localizedDescription)")
        }
    }

    func uploadProfilePicture(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let user = Auth.auth().currentUser else {
            alertItem = AlertItem(title: "Error", message: "Failed to upload profile picture.")
            return
        }

        let storageRef = Storage.storage().reference().child("profile_pictures/\(user.uid).jpg")
        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            if let error = error {
                self?.alertItem = AlertItem(title: "Error", message: error.localizedDescription)
            } else {
                print("Profile picture uploaded successfully.")
            }
        }
    }
}


