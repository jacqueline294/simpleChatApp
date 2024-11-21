//
//  ChatViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var errorMessage: String?

    func signUp(email: String, password: String, name: String, profileImage: UIImage?, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, "Registration failed: \(error.localizedDescription)")
                return
            }

            guard let userId = result?.user.uid else {
                completion(false, "User ID not found")
                return
            }

            // Handle profile picture upload if available
            if let image = profileImage {
                self.uploadProfileImage(userId: userId, image: image) { url in
                    self.saveUserToFirestore(userId: userId, name: name, email: email, profilePictureURL: url, completion: completion)
                }
            } else {
                // Save user without profile picture
                self.saveUserToFirestore(userId: userId, name: name, email: email, profilePictureURL: nil, completion: completion)
            }
        }
    }
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    completion(false, "Login failed: \(error.localizedDescription)")
                    return
                }

                // Successful login
                if let userId = result?.user.uid {
                    print("User logged in with ID: \(userId)")
                    completion(true, nil)
                } else {
                    completion(false, "Login failed: Unable to fetch user ID.")
                }
            }
        }
    
    private func uploadProfileImage(userId: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("profilePictures/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                self.errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
                completion(nil)
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    self.errorMessage = "Failed to retrieve profile picture URL: \(error.localizedDescription)"
                    completion(nil)
                    return
                }

                completion(url?.absoluteString)
            }
        }
    }

    private func saveUserToFirestore(userId: String, name: String, email: String, profilePictureURL: String?, completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        let userDocument: [String: Any] = [
            "name": name,
            "email": email,
            "profilePictureURL": profilePictureURL ?? ""
        ]

        db.collection("users").document(userId).setData(userDocument) { error in
            if let error = error {
                completion(false, "Failed to save user: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
    func updateUser() {
            if let firebaseUser = Auth.auth().currentUser {
                self.user = User(firebaseUser: firebaseUser)
            } else {
                self.user = nil
      }
   }
}
