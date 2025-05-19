//
//  MultipleSelectionRow.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//
import SwiftUI

struct MultipleSelectionRow: View {
    let user: User
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                // Profile image
                if let urlString = user.profileImageURL, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 40, height: 40)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }

                // Name
                Text(user.name)
                    .foregroundColor(.primary)
                    .padding(.leading, 8)

                Spacer()

                // Checkmark if selected
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding(.vertical, 4)
        }
    }
}


