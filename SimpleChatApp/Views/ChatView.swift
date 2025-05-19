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
    
    init(user: User, chatId: String) {
        self.user = user
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel())
    }
    
    var body: some View {
        VStack {
            // User profile section
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

            // Messages View
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
            
            ZStack(alignment: .trailing) {
                TextField("Message", text: $viewModel.newMessage, axis: .vertical)
                    .padding(12)
                    .padding(.trailing, 40)
                    .background(Color(.systemGroupedBackground))
                    .clipShape(Capsule())
                    .font(.subheadline)
                
                Button(action: {
                    viewModel.sendMessage(toChat: chatId)
                }) {
                    Text("Send")
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMessages(forChat: chatId)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyUser = User(id: "123", name: "John Doe", email: "john@example.com", profileImageURL: nil)
        ChatView(user: dummyUser, chatId: "dummyChatId")
    }
}
