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
        imageUrl != nil
    }

    enum CodingKeys: String, CodingKey {
        case id, text, senderId, timestamp, imageUrl, groupId
    }
}

