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
            }
            .onAppear {
                #if DEBUG
                print("Loading mock users for the simulator")
                viewModel.preloadMockUsers()
                #else
                print("Fetching real users from Firebase")
                viewModel.fetchUsers()
                #endif
            }
        }
    }
}

#Preview {
    InboxView()
}


