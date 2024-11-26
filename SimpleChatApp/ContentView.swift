//
//  ContentView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var path: [Destination] = [] // Change from [String] to [Destination]

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if viewModel.user == nil {
                    RegistrationView(viewModel: viewModel, path: $path)
                } else {
                    ProfileView(authViewModel: viewModel, path: $path) // Pass path for further navigation
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination.type {
                case .inbox:
                    InboxView(path: $path) // Pass the path binding to InboxView
                case .chat(let user, let chatId):
                    ChatView(user: user, chatId: chatId)
                }
            }
        }
        .onAppear {
            viewModel.setupAuthListener()
        }
    }
}

#Preview {
    ContentView()
}
