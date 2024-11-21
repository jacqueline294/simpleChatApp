//
//  InboxView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth

struct InboxView: View {
    @StateObject private var viewModel = InboxViewModel() // Use the InboxViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    // Show loading state
                    ProgressView("Loading users...")
                } else if let errorMessage = viewModel.errorMessage {
                    // Show error message
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // List of users
                    List(viewModel.users) { user in
                        NavigationLink(destination: ChatView(chatId: user.id)) {
                            HStack {
                                // Display profile picture
                                if let urlString = user.profilePictureURL, let url = URL(string: urlString) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                } else {
                                    // Fallback for missing profile pictures
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                }

                                // Display user name and email
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
                    .listStyle(PlainListStyle())
                }
            }
            .onAppear {
                viewModel.fetchUsers() // Fetch users when the view appears
            }
            .navigationTitle("Inbox")
        }
    }
}
#Preview {
    InboxView()
}

