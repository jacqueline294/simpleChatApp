//
//  ContentView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var path: [Destination] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if viewModel.user == nil {
                    RegistrationView(viewModel: viewModel, path: $path)
                } else {
                    InboxView(viewModel: viewModel, path: $path)
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination.type {
                case .chat(let user, let chatId):
                    ChatView(user: user, chatId: chatId)
                    
                case .groupChat(let group):
                    GroupChatView(groupId: group.id)  // ✅ Show group chat
                    
                case .groupCreation:
                    GroupCreationView(path: $path)    // ✅ Show group creation screen
                    
                case .login:
                    LoginView(viewModel: viewModel, path: $path)
                    
                case .inbox:
                    InboxView(viewModel: viewModel, path: $path)
                    
                case .profile:
                    ProfileView(path: $path)
                        .environmentObject(viewModel)
                    
                @unknown default:
                    Text("Unknown Destination")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
