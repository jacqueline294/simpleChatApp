//
//  ChatView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    var chatId: String

    var body: some View {
        VStack {
            // Header
            Text("Chat with \(viewModel.messages.first?.senderId ?? "your friend")")
                .font(.headline)
                .padding()

            // Messages List
            if viewModel.messages.isEmpty {
                Text("No messages yet. Start the conversation!")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    ForEach(viewModel.messages, id: \.id) { message in
                        HStack {
                            if message.senderId == Auth.auth().currentUser?.uid {
                                Spacer()
                                Text(message.text)
                                    .padding()
                                    .background(Color.blue.opacity(0.3))
                                    .cornerRadius(8)
                            } else {
                                Text(message.text)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                                Spacer()
                            }
                        }
                    }
                }
            }

            // Input Field
            HStack {
                TextField("Type a message...", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    viewModel.sendMessage(toChat: chatId)
                }) {
                    Text("Send")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchMessages(forChat: chatId)
        }
    }
}

// #Preview directive
#Preview {
    ChatView(chatId: "")
}

