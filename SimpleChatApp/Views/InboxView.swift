//
//  InboxView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseAuth

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                } else if viewModel.users.isEmpty {
                    Text("No chats available. Start a new conversation!")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(viewModel.users, id: \.id) { user in
                        NavigationLink(destination: ChatView(chatId: user.id)) {
                            Text(user.name)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}

#Preview {
    InboxView()
}

