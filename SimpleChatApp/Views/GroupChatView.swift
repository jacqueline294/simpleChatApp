//
//  GroupChatView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import SwiftUI

struct GroupChatView: View {
    @StateObject var viewModel = GroupChatViewModel()
    let groupId: String

    @State private var newMessage = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        ZStack {
            // 🌈 Background gradient
            LinearGradient(colors: [Color.cyan.opacity(0.1), Color.indigo.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 🧾 Messages section
                if viewModel.messages.isEmpty {
                    Spacer()
                    Text("No messages yet")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                HStack(alignment: .bottom) {
                                    if message.senderId == viewModel.currentUserId {
                                        Spacer()
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        if let imageUrl = message.imageUrl,
                                           let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { phase in
                                                switch phase {
                                                case .empty:
                                                    ProgressView()
                                                case .success(let image):
                                                    image
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(maxWidth: 200)
                                                        .cornerRadius(10)
                                                case .failure:
                                                    Image(systemName: "photo")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 200, height: 150)
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        }

                                        if !message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            Text(message.text)
                                                .padding(10)
                                                .background(message.senderId == viewModel.currentUserId ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(message.senderId == viewModel.currentUserId ? .white : .black)
                                                .cornerRadius(12)
                                        }
                                    }

                                    if message.senderId != viewModel.currentUserId {
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }

                // 🧾 Input area
                HStack(spacing: 12) {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }

                    TextField("Message", text: $newMessage)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.subheadline)

                    Button(action: {
                        viewModel.sendMessage(newMessage, groupId: groupId, senderId: viewModel.currentUserId)
                        newMessage = ""
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                viewModel.sendImage(image, to: groupId)
                selectedImage = nil
            }
        }
        .onAppear {
            viewModel.fetchMessages(for: groupId)
        }
        .onDisappear {
            viewModel.detachListener()
        }
        .navigationTitle("Group Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}
