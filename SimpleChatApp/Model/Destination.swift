//
//  Destination.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import Foundation
import SwiftUI

struct Destination: Hashable {
    let id: UUID
    let type: DestinationType

    enum DestinationType: Hashable {
        case inbox
        case chat(User, String)// User and chatId
        case login
    }
}
