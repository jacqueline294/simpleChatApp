//
//  InboxView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel() // Inbox view model
    @State private var selectedUser: User? = nil
    @Binding var path: [Destination] // Use binding to update the main navigation stack

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List(viewModel.users) { user in
                    Button(action: {
                        // Get or create chat ID, then navigate to ChatView
                        viewModel.getOrCreateChatId(with: user.id) { chatId in
                            if let chatId = chatId {
                                DispatchQueue.main.async {
                                    viewModel.selectedChatId = chatId
                                    selectedUser = user
                                    if let selectedUser = selectedUser {
                                        path.append(Destination(id: UUID(), type: .chat(selectedUser, chatId)))
                                    }
                                }
                            }
                        }
                    }) {
                        HStack {
                            if let profileImageUrl = user.profileImageURL, let url = URL(string: profileImageUrl) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    case .failure:
                                        Image(systemName: "person.crop.circle.fill").resizable().scaledToFill()
                                    @unknown default:
                                        ProgressView()
                                    }
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            }
                            VStack(alignment: .leading) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .navigationTitle("Inbox")
                .navigationDestination(for: Destination.self) { destination in
                    switch destination.type {
                    case .inbox:
                        InboxView(path: $path)
                    case .chat(let user, let chatId):
                        ChatView(user: user, chatId: chatId)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(path: .constant([]))
    }
}
