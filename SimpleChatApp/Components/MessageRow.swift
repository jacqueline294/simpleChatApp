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
        HStack(alignment: .bottom) {
            if isCurrentUser { Spacer() }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 8) {
                // Display image if present
                if message.isImage, let urlStr = message.imageUrl, let url = URL(string: urlStr) {
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
                            Image(systemName: "photo") // Standard icon for failed image load
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 150)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // Display text if not empty.
                // This applies to text-only messages, or text accompanying an image.
                // It will not render if text is empty (e.g. image-only message).
                if !message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(message.text)
                        .padding(10)
                        .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(isCurrentUser ? .white : .black)
                        .cornerRadius(10)
                        .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)
                }
            }

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
