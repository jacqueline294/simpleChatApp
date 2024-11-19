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
    @StateObject private var viewModel = ChatViewModel() // Initialize the ViewModel
    var chatId: String // The ID of the chat (e.g., conversation)

    var body: some View {
        VStack {
            // Header
            Text("Chat with \(viewModel.messages.first?.senderName ?? "Unknown")")
                .font(.headline)
                .padding()

            // Messages List
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        Text(message.content)
                            .padding()
                            .background(message.senderId == Auth.auth().currentUser?.uid ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: message.senderId == Auth.auth().currentUser?.uid ? .trailing : .leading)
                    }
                }
            }
            .padding()

            // Message Input
            HStack {
                TextField("Type a message", text: $viewModel.newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 40)

                Button(action: {
                    viewModel.sendMessage(toChat: chatId)
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchMessages(forChat: chatId) // Fetch messages for the chat
        }
        
    }
}

#Preview {
    ChatView(chatId: "")
}

