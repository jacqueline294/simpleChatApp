//
//  Destination.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import Foundation
import SwiftUI

enum DestinationType: Hashable {
    case inbox
    case chat(User, String)
    case login
    case profile
}

struct Destination: Hashable {
    let id: UUID
    let type: DestinationType

    
}
