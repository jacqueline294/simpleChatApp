//
//  ChatDestination.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import Foundation

struct ChatDestination: Hashable {
    let user: User
    let chatId: String
    
    enum DestinationType: Hashable {
            case inbox
            case chat(User, String) 
        }
}
