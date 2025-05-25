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

struct User: Identifiable, Decodable,Hashable, Equatable {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String?
    var fcmToken: String? = nil
}


