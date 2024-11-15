//
//  ChatViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import Foundation
import FirebaseAuth
import Combine

enum AuthState {
    case loggedIn
    case loggedOut
}

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil // Firebase user object
    @Published var authState: AuthState = .loggedOut // Tracks current authentication state

    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        // Listen for authentication state changes
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.authState = user == nil ? .loggedOut : .loggedIn
            }
        }
    }

    deinit {
        // Remove the auth state listener when this object is deallocated
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Authentication Methods

    /// Sign up with email and password
    func signUp(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                completion(false, "Failed to create user.")
                return
            }

            self?.user = user
            self?.authState = .loggedIn
            completion(true, nil)
        }
    }

    /// Log in with email and password
    func login(email: String, password: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                completion(false, "Failed to log in.")
                return
            }

            self?.user = user
            self?.authState = .loggedIn
            completion(true, nil)
        }
    }

    /// Log out the current user
    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.authState = .loggedOut
        } catch let error {
            print("Failed to log out: \(error.localizedDescription)")
        }
    }
}
