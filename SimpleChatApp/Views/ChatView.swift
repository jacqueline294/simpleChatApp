//
//  ChatView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    let user: User
    let chatId: String

    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    init(user: User, chatId: String) {
        self.user = user
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel())
    }

    var body: some View {
        ZStack {
            // 🌈 Soft background
            LinearGradient(colors: [Color.mint.opacity(0.1), Color.teal.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 📌 Profile header
                HStack(spacing: 12) {
                    if let url = URL(string: user.profileImageURL ?? "") {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable().scaledToFill()
                            case .failure:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFill()
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
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.green)
                    }

                    Spacer()
                }
                .padding(.horizontal)

                Divider()

                // 🧾 Messages
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            HStack(alignment: .bottom) {
                                if message.senderId == user.id {
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
                                            .background(message.senderId == user.id ? Color.blue : Color.gray.opacity(0.2))
                                            .foregroundColor(message.senderId == user.id ? .white : .black)
                                            .cornerRadius(12)
                                    }
                                }

                                if message.senderId != user.id {
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }

                // 🧾 Input
                HStack(spacing: 12) {
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }

                    TextField("Type a message...", text: $viewModel.newMessage, axis: .vertical)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.subheadline)

                    Button(action: {
                        viewModel.sendMessage(toChat: chatId)
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
                viewModel.sendImage(image, to: chatId)
                selectedImage = nil
            }
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMessages(forChat: chatId)
        }
    }
}
