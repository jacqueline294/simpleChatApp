//
//  User.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-18.
//

import Foundation
import Firebase
import FirebaseFirestore

public struct User: Codable, Identifiable, Hashable{
    public  let  id : String
    public  let name : String
    public let email: String
    public let password : String
}
