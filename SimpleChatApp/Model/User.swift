//
//  User.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-18.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct User: Identifiable {
    let id: String
    let name: String
    let email: String
    let profilePictureURL: String?
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? "Unknown"
        self.email = firebaseUser.email ?? "No Email"
        self.profilePictureURL = firebaseUser.photoURL?.absoluteString
    }
}
