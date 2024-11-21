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
            Text("Chat with \(viewModel.messages.first?.senderName ?? "your friend")")
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
            Task {
                await viewModel.fetchMessages(forChat: chatId)
            }
        }
    }
}

// Mock data for preview
extension ChatViewModel {
    static var mock: ChatViewModel {
        let viewModel = ChatViewModel()
        viewModel.messages = [
            Message(id: "1", content: "Hello!", senderId: "user1", senderName: "Alice", timestamp: Date()),
            Message(id: "2", content: "Hi there!", senderId: "user2", senderName: "Bob", timestamp: Date())
        ]
        return viewModel
    }
}

// #Preview directive
#Preview {
    ChatView(chatId: "mockChat")
        .environmentObject(ChatViewModel.mock)
}

