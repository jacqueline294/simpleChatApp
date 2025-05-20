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
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
                // 🖼 Render image if available
                if let urlString = message.imageUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 200, height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200)
                                .cornerRadius(12)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 150)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // ✏️ Render text if not empty
                if !message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(message.text)
                        .padding(10)
                        .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                        .foregroundColor(isCurrentUser ? .white : .black)
                        .cornerRadius(8)
                        .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
                }
            }

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
