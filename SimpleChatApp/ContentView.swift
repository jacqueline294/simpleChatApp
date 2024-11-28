//
//  ContentView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()  // Initialize AuthViewModel
    @State private var path: [Destination] = []  // Manages navigation in the app

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if viewModel.user == nil {
                    // Show registration or login view if the user is not logged in
                    RegistrationView(viewModel: viewModel, path: $path)
                } else {
                    // Show the inbox when the user is logged in
                    InboxView(viewModel: viewModel, path: $path)
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination.type {
                case .chat(let user, let chatId):
                    ChatView(user: user, chatId: chatId)
                case .login:
                    LoginView(viewModel: viewModel, path: $path)
                case .inbox:
                    InboxView(viewModel: viewModel, path: $path)
                case .profile:
                    ProfileView(path: $path)
                        .environmentObject(viewModel) // Pass viewModel as an environment object
                @unknown default:
                    Text("Unknown Destination")
                }
            }
        }
        .onAppear {
            viewModel.setupAuthListener()
        }
        .environmentObject(viewModel)  // Provide viewModel to all child views
    }
}


#Preview {
    ContentView()
}
