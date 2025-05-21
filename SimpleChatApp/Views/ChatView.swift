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
    @State private var errorText: String = ""
    @State private var showError: Bool = false

    init(user: User, chatId: String) {
        self.user = user
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel())
    }

    var body: some View {
        ZStack {
            // 🌈 Background
            LinearGradient(colors: [Color.teal.opacity(0.1), Color.indigo.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 🧾 Messages
                if viewModel.messages.isEmpty {
                    Spacer()
                    Text("Start chatting with \(user.name)")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                HStack(alignment: .bottom) {
                                    if message.senderId == Auth.auth().currentUser?.uid {
                                        Spacer()
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        // 🖼 Image if any
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
                                                .background(message.senderId == Auth.auth().currentUser?.uid ? Color.blue : Color.gray.opacity(0.2))
                                                .foregroundColor(message.senderId == Auth.auth().currentUser?.uid ? .white : .black)
                                                .cornerRadius(12)
                                        }
                                    }

                                    if message.senderId != Auth.auth().currentUser?.uid {
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }

                // 🧾 Input
                HStack(spacing: 12) {
                    // 📷 Image button
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }

                    // ✏️ Text input
                    TextField("Type a message...", text: $viewModel.newMessage, axis: .vertical)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.subheadline)

                    // 🚀 Send
                    Button {
                        if viewModel.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            errorText = "Message is empty."
                            showError = true
                        } else {
                            viewModel.sendMessage(toChat: chatId)
                        }
                    } label: {
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
                if let image = selectedImage {
                    viewModel.sendImage(image, to: chatId)
                    selectedImage = nil
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorText)
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMessages(forChat: chatId)
        }
    }
}

