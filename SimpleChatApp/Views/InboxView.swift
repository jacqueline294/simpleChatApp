//
//  InboxView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading users...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if viewModel.users.isEmpty {
                Text("No chats available. Start a new conversation!")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                List(viewModel.users, id: \.id) { user in
                    NavigationLink(destination: ChatView(chatId: user.id)) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Inbox")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Always fetch real users instead of using mock users
            viewModel.fetchUsers()
        }
    }
}

#Preview {
    InboxView()
}





