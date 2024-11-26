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

struct User: Identifiable, Decodable {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String?
}


