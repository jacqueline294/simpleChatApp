//
//  ChatViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import Foundation
import FirebaseAuth

//Manages the navigation and user authentication status
class AuthViewModel: ObservableObject {
    
    @Published var currentState: AppFlowState = .login
    @Published var user: User?
    
    func login (email: String, password: String) {
        Auth.auth().signIn(withEmail: email,password: password){ [weak self] result, error in
            if let error = error{
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            self?.user = result?.user
            self?.currentState = .inbox
        }
    }
    func Register(email: String, password: String) {
        Auth.auth().signIn(withEmail: email,password: password){ [weak self] result, error in
            if let error = error{
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            self?.user = result?.user
            self?.currentState = .inbox
        }
    }
    func logout() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.currentState = .login
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

}
