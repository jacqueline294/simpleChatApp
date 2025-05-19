//
//  ProfileViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage? = nil
    @Published var name: String = "Loading..."
    @Published var email: String = "Loading..."
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    func fetchProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        isLoading = true
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }

                guard let data = document?.data() else {
                    self?.errorMessage = "No profile data found"
                    return
                }

                self?.name = data["name"] as? String ?? "No Name"
                self?.email = data["email"] as? String ?? "No Email"

                if let profileImageURL = data["profileImageURL"] as? String,
                   let url = URL(string: profileImageURL) {
                    self?.loadImage(from: url)
                }
            }
        }
    }

    private func loadImage(from url: URL) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }

    func updateProfile(name: String, profileImage: UIImage?) {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.errorMessage = "User not authenticated"
            return
        }

        var userData: [String: Any] = ["name": name]
        if let profileImage = profileImage {
            uploadProfileImage(userId: userId, image: profileImage) { [weak self] imageURL in
                if let imageURL = imageURL {
                    userData["profileImageURL"] = imageURL
                }
                self?.saveProfileData(userId: userId, userData: userData)
            }
        } else {
            saveProfileData(userId: userId, userData: userData)
        }
    }

    private func saveProfileData(userId: String, userData: [String: Any]) {
        db.collection("users").document(userId).updateData(userData) { [weak self] error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
            } else {
                self?.fetchProfile() // Refresh profile data
            }
        }
    }

    private func uploadProfileImage(userId: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = storage.reference().child("profileImages/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(nil)
                return
            }

            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
}
