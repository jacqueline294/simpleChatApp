//
//  Message.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-16.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let text: String
    let senderId: String
    let timestamp: Date
    var imageUrl: String?
    var groupId: String

    var isImage: Bool { imageUrl != nil }

    enum CodingKeys: String, CodingKey {
        case id
        case text        // ✅ corrected from 'content'
        case senderId
        case timestamp
        case imageUrl
        case groupId
    }
}
