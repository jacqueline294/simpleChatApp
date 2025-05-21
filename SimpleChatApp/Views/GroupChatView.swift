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
    @State private var showError = false
    @State private var errorText = ""

    var body: some View {
        ZStack {
            // 🌈 Gradient background
            LinearGradient(colors: [Color.cyan.opacity(0.1), Color.indigo.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 🔄 Loading indicator
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading messages...")
                        .padding()
                    Spacer()
                } else if viewModel.messages.isEmpty {
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
                                        // 🖼 Image
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

                                        // 💬 Text
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

                // 💬 Message input
                HStack(spacing: 12) {
                    // 📷 Image button
                    Button {
                        showingImagePicker = true
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }

                    // 📝 TextField
                    TextField("Message", text: $newMessage)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.subheadline)

                    // 📨 Send
                    Button {
                        if newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            errorText = "Cannot send empty message."
                            showError = true
                            return
                        }

                        viewModel.sendMessage(newMessage, groupId: groupId, senderId: viewModel.currentUserId)
                        newMessage = ""
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
                    viewModel.sendImage(image, to: groupId)
                    selectedImage = nil
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorText)
        }
        .navigationTitle("Group Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMessages(for: groupId)
        }
        .onDisappear {
            viewModel.detachListener()
        }
    }
}
