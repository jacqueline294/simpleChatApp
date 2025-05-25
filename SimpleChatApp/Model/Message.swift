//
//  Message.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let senderId: String
    let timestamp: Date
    var imageUrl: String?
    var groupId: String

    var isImage: Bool {
        imageUrl != nil // Reverted to original logic
    }

    enum CodingKeys: String, CodingKey {
        case id, text, senderId, timestamp, imageUrl, groupId // Removed 'type'
    }
    
    // Removed custom initializer that included 'type'.
    // The default memberwise initializer will be used, or if a specific one was present before,
    // this effectively reverts to it if it matched the properties now available.
    // If a specific initializer was like:
    // init(id: String, text: String, senderId: String, timestamp: Date, imageUrl: String? = nil, groupId: String) {
    //    self.id = id
    //    self.text = text
    //    self.senderId = senderId
    //    self.timestamp = timestamp
    //    self.imageUrl = imageUrl
    //    self.groupId = groupId
    // }
    // It is implicitly restored by removing the one with 'type'.
}

