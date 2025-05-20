//
//  ChatView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//
import SwiftUI

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    let user: User
    let chatId: String

    // ✅ Image sending state
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    init(user: User, chatId: String) {
        self.user = user
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel())
    }

    var body: some View {
        VStack {
            // Profile header
            if let profileImageUrl = user.profileImageURL, let url = URL(string: profileImageUrl) {
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
                .frame(width: 100, height: 100)
                .clipShape(Circle())

                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Messenger")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.bottom)
            }

            // Messages list
            ScrollView {
                VStack {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.senderId == user.id {
                                Spacer()
                                Text(message.text)
                                    .padding(10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .frame(maxWidth: 250, alignment: .trailing)
                            } else {
                                Text(message.text)
                                    .padding(10)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .frame(maxWidth: 250, alignment: .leading)
                                Spacer()
                            }
                        }
                        .id(message.id)
                    }
                }
                .padding()
            }

            Spacer()

            // Text input + Image button
            HStack(spacing: 10) {
                // 📷 image picker button
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .imageScale(.large)
                }

                // TextField
                TextField("Message", text: $viewModel.newMessage, axis: .vertical)
                    .padding(12)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(Capsule())
                    .font(.subheadline)

                // Send button
                Button(action: {
                    viewModel.sendMessage(toChat: chatId)
                }) {
                    Text("Send")
                        .fontWeight(.semibold)
                }
            }
            .padding()
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
