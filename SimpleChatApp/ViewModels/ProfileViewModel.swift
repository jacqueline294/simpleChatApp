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
    @Published var isLoading: Bool = false // Added loading state

    private let db = Firestore.firestore()

    func fetchProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        isLoading = true
        db.collection("users").document(userId).getDocument { document, error in
            self.isLoading = false
            if let error = error {
                print("Error fetching profile: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else { return }
            self.name = data["name"] as? String ?? "No Name"
            self.email = data["email"] as? String ?? "No Email"

            if let profileImageURL = data["profileImageURL"] as? String,
               let url = URL(string: profileImageURL) {
                self.loadImage(from: url)
            }
        }
    }

    private func loadImage(from url: URL) {
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            } else {
                DispatchQueue.main.async {
                    print("Failed to load profile image from URL")
                }
            }
        }
    }

    func updateProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to data")
            return
        }

        let storageRef = Storage.storage().reference().child("profileImages/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Error fetching download URL: \(error.localizedDescription)")
                    return
                }

                if let url = url {
                    self.db.collection("users").document(userId).updateData([
                        "profileImageURL": url.absoluteString
                    ]) { error in
                        if let error = error {
                            print("Error updating Firestore: \(error.localizedDescription)")
                        } else {
                            print("Profile image URL successfully updated in Firestore")
                        }
                    }
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isLoggedOut = true
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
