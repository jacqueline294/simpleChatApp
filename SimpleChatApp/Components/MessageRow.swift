//
//  MessageRow.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import SwiftUI

struct MessageRow: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct MessageRow_Previews: PreviewProvider {
    static var previews: some View {
        let dummyMessage = Message(
            id: "1",
            text: "Hello, world!",
            senderId: "123",
            timestamp: Date(),
            imageUrl: nil,
            groupId: "test-group"
        )
        MessageRow(message: dummyMessage, isCurrentUser: true)
    }
}


