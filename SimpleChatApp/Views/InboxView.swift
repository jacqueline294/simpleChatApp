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
        VStack {
            // Title for the Inbox
            Text("Inbox")
                .font(.largeTitle)
                .bold()
                .padding()

            // List of Users (Scrollable)
            List(inboxViewModel.users) { user in
                Button(action: {
                    inboxViewModel.getOrCreateChatId(with: user.id) { chatId in
                        if let chatId = chatId {
                            DispatchQueue.main.async {
                                path.append(Destination(id: UUID(), type: .chat(user, chatId)))
                            }
                        }
                    }
                }) {
                    HStack {
                        if let profileImageUrl = user.profileImageURL,
                           let url = URL(string: profileImageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                case .failure:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                @unknown default:
                                    ProgressView()
                                        .frame(width: 50, height: 50)
                                }
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
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
            .onAppear {
                inboxViewModel.fetchUsers()
            }
            .navigationTitle("Inbox")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        path.append(Destination(id: UUID(), type: .profile))
                    }) {
                        Text("Profile")
                            .foregroundColor(.blue)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        path.append(Destination(id: UUID(), type: .groupCreation))
                    }) {
                        Image(systemName: "person.3.fill")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                            .accessibilityLabel("Start Group Chat")
                    }
                }
            }
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(viewModel: AuthViewModel(), path: .constant([]))
            .previewDisplayName("Inbox View Preview")
    }
}
