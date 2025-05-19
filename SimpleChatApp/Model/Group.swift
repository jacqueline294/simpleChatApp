//
//  Group.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import Foundation

struct Group: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var members: [String]
}
