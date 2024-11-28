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
    @State private var path: [Destination] = [] // Manages navigation in the app

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                if viewModel.user == nil {
                    RegistrationView(viewModel: viewModel, path: $path) // Make sure RegistrationView accepts Binding<[Destination]>
                } else {
                    InboxView(viewModel: viewModel, path: $path) // Make sure InboxView also accepts Binding<[Destination]>
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
                    ProfileView(authViewModel: viewModel, path: $path)
                @unknown default:
                    Text("Unknown Destination")
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
