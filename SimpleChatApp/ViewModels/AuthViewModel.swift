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
    
    init() {
        setupAuthListener() // Automatically starts listening when the view model is initialized
    }

   //Authentication Listener
    func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self = self else { return }
            if let firebaseUser = firebaseUser {
                self.fetchUserFromFirestore(userId: firebaseUser.uid) { success, error in
                    if let error = error {
                        self.errorMessage = error
                    }
                }
            } else {
                self.user = nil
            }
        }
    }
    
    //  User Sign-Up
    func signUp(email: String, password: String, name: String, profileImage: UIImage?, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false, error.localizedDescription)
                return
            }
            
            guard let userId = result?.user.uid else {
                self.errorMessage = "Failed to fetch user ID"
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
                    guard let imageURL = imageURL else {
                        completion(false, "Failed to upload profile image")
                        return
                    }
                    userData["profileImageURL"] = imageURL
                    self.saveUserToFirestore(userId: userId, userData: userData, completion: completion)
                }
            } else {
                self.saveUserToFirestore(userId: userId, userData: userData, completion: completion)
            }
        }
    }
    
    //  User Login
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false, error.localizedDescription)
                return
            }
            
            guard let userId = result?.user.uid else {
                self.errorMessage = "Failed to fetch user ID"
                completion(false, "Failed to fetch user ID")
                return
            }
            
            self.fetchUserFromFirestore(userId: userId, completion: completion)
        }
    }
    
    //  User Logout
    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = "Error logging out: \(error.localizedDescription)"
        }
    }
    
    //  Update User
    func updateUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.user = nil
            return
        }
        self.fetchUserFromFirestore(userId: userId) { _, _ in }
    }
    
    //  save user to firestore
    private func saveUserToFirestore(userId: String, userData: [String: Any], completion: @escaping (Bool, String?) -> Void) {
        db.collection("users").document(userId).setData(userData) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false, error.localizedDescription)
            } else {
                self.fetchUserFromFirestore(userId: userId, completion: completion)
            }
        }
    }
    
    private func fetchUserFromFirestore(userId: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                self.errorMessage = error.localizedDescription
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = document?.data(),
                  let name = data["name"] as? String,
                  let email = data["email"] as? String else {
                self.errorMessage = "Failed to fetch user profile"
                completion(false, "Failed to fetch user profile")
                return
            }
            
            let profileImageURL = data["profileImageURL"] as? String
            self.user = User(id: userId, name: name, email: email, profileImageURL: profileImageURL)
            completion(true, nil)
        }
    }
    
    private func uploadProfileImage(userId: String, image: UIImage, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storageRef = Storage.storage().reference().child("profileImages/\(userId).jpg")
        storageRef.putData(imageData, metadata: nil) { [weak self] _, error in
            guard let self = self else { return }
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
