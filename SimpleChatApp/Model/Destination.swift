//
//  Destination.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import Foundation

struct Destination: Hashable, Identifiable {
    let id: UUID
    let type: DestinationType
}

enum DestinationType: Hashable {
    case inbox
    case chat(User, String)
    case groupChat(Group)
    case groupCreation
    case login
    case profile
}
