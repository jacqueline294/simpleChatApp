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

    private let db = Firestore.firestore()

    func signUp(email: String, password: String, name: String, profileImage: UIImage?, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let userId = result?.user.uid else {
                completion(false, "Failed to fetch user ID")
                return
            }

            var userData: [String: Any] = [
                "name": name,
                "email": email,
                "createdAt": FieldValue.serverTimestamp()
            ]

            if let profileImage = profileImage {
                self.uploadProfileImage(userId: userId, image: profileImage) { imageURL in
                    userData["profileImageURL"] = imageURL
                    self.db.collection("users").document(userId).setData(userData) { error in
                        if let error = error {
                            completion(false, error.localizedDescription)
                        } else {
                            completion(true, nil)
                        }
                    }
                }
            } else {
                self.db.collection("users").document(userId).setData(userData) { error in
                    if let error = error {
                        completion(false, error.localizedDescription)
                    } else {
                        completion(true, nil)
                    }
                }
            }
        }
    }

    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let userId = result?.user.uid else {
                completion(false, "Failed to fetch user ID")
                return
            }

            self.db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                guard let data = document?.data(),
                      let name = data["name"] as? String,
                      let email = data["email"] as? String else {
                    completion(false, "Failed to fetch user profile")
                    return
                }

                self.user = User(id: userId, name: name, email: email,firebaseUser: Auth.auth().currentUser!)
                completion(true, nil)
            }
        }
    }

    private func uploadProfileImage(userId: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference().child("profileImages/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            storageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }
}
