//
//  Message.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-16.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var received: Bool
    var timestamp: Date
}
