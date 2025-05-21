//
//  InboxView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import Foundation

struct InboxView: View {
    @ObservedObject var viewModel: AuthViewModel
    @StateObject private var inboxViewModel = InboxViewModel()
    @Binding var path: [Destination]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.teal.opacity(0.05), Color.mint.opacity(0.1)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                Text("ChitChat Inbox")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 10)

                List {
                    //  Group Chats
                    if !inboxViewModel.groups.isEmpty {
                        Section(header: Text("Group Chats").font(.headline)) {
                            ForEach(inboxViewModel.groups, id: \.id) { group in
                                Button {
                                    path.append(Destination(id: UUID(), type: .groupChat(group)))
                                } label: {
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(Color.blue.opacity(0.2))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "person.3.fill")
                                                    .foregroundColor(.blue)
                                            )

                                        Text(group.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Spacer()

                                        // 🔴 Unread badge (placeholder logic)
                                        if Bool.random() { // Replace with real unread logic
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        inboxViewModel.deleteGroup(group)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    // 👤 Private Chats
                    Section(header: Text("Chats").font(.headline)) {
                        ForEach(inboxViewModel.users) { user in
                            Button {
                                inboxViewModel.getOrCreateChatId(with: user.id) { chatId in
                                    if let chatId = chatId {
                                        DispatchQueue.main.async {
                                            path.append(Destination(id: UUID(), type: .chat(user, chatId)))
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    if let profileURL = user.profileImageURL,
                                       let url = URL(string: profileURL) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                ProgressView()
                                            case .success(let image):
                                                image.resizable()
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            default:
                                                Image(systemName: "person.crop.circle.fill")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 40, height: 40)
                                                    .clipShape(Circle())
                                            }
                                        }
                                    } else {
                                        Circle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(initials(for: user.name))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            )
                                    }

                                    VStack(alignment: .leading) {
                                        Text(user.name)
                                            .font(.headline)
                                        Text(user.email)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .animation(.easeInOut, value: inboxViewModel.groups)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        path.append(Destination(id: UUID(), type: .profile))
                    } label: {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        path.append(Destination(id: UUID(), type: .groupCreation))
                    } label: {
                        Label("New Group", systemImage: "plus.bubble.fill")
                    }
                }
            }
            .onAppear {
                inboxViewModel.fetchUsers()
                inboxViewModel.fetchGroups()
            }
        }
    }

    //  Fallback initials for user avatar
    private func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.prefix(2).map { String($0.prefix(1)) }.joined().uppercased()
    }
}


struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(viewModel: AuthViewModel(), path: .constant([]))
            .previewDisplayName("Inbox View Preview")
    }
}
