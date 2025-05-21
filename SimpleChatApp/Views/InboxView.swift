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
            //  Background gradient
            LinearGradient(
                colors: [Color.mint.opacity(0.1), Color.teal.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                //  Header
                HStack {
                    Text("Inbox")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                    Spacer()
                    Button {
                        path.append(Destination(id: UUID(), type: .groupCreation))
                    } label: {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // 🧑‍🤝‍🧑 User List
                List {
                    ForEach(inboxViewModel.users) { user in
                        Button(action: {
                            inboxViewModel.getOrCreateChatId(with: user.id) { chatId in
                                if let chatId = chatId {
                                    DispatchQueue.main.async {
                                        path.append(Destination(id: UUID(), type: .chat(user, chatId)))
                                    }
                                }
                            }
                        }) {
                            HStack(spacing: 16) {
                                // Profile image
                                if let urlString = user.profileImageURL, let url = URL(string: urlString) {
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
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.gray)
                                }

                                // User info
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        .listRowBackground(Color.white.opacity(0.95))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    path.append(Destination(id: UUID(), type: .profile))
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                }
            }
        }
        .onAppear {
            inboxViewModel.fetchUsers()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView(viewModel: AuthViewModel(), path: .constant([]))
            .previewDisplayName("Inbox View Preview")
    }
}
