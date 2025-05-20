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
        VStack {
            if viewModel.messages.isEmpty {
                Spacer()
                Text("No messages yet")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.messages) { message in
                            MessageRow(
                                message: message,
                                isCurrentUser: message.senderId == viewModel.currentUserId
                            )
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                // 📷 Image Button
                Button(action: {
                    showingImagePicker = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .imageScale(.large)
                }

                // 📝 Message Input
                TextField("Message", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // 🚀 Send Button
                Button("Send") {
                    viewModel.sendMessage(
                        newMessage,
                        groupId: groupId,
                        senderId: viewModel.currentUserId
                    )
                    newMessage = ""
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                viewModel.sendImage(image, to: groupId)
                selectedImage = nil
            }
        }
        .onAppear {
            print("👀 GroupChatView appeared for groupId: \(groupId)")
            viewModel.fetchMessages(for: groupId)
        }
        .onDisappear {
            viewModel.detachListener()
        }
        .navigationTitle("Group Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
}
