//
//  Message.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-16.
//

import Foundation


struct Message: Identifiable {
    let id: String
    let text: String
    let senderId: String
    let timestamp: Date
}


