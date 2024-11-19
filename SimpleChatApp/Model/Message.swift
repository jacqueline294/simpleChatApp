//
//  Message.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-16.
//

import Foundation
import FirebaseFirestore

struct Message: Codable, Identifiable {
    @DocumentID var id: String? // Firestore document ID
    let content: String
    let senderId: String
    let senderName: String
    let timestamp: Date
}
