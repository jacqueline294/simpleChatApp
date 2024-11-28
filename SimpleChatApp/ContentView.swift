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
    @State private var path: [Destination] = [] // manages navigation in the app 
    var body: some View {
        NavigationStack(path: $path) {
            Group {
                //if the user is not authenicated it shows registrationView else profile
                if viewModel.user == nil {
                    RegistrationView(viewModel: viewModel, path: $path)
                } else {
                    ProfileView(authViewModel: viewModel, path: $path)
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination.type {
                case .inbox:
                    InboxView(path: $path)
                case .chat(let user, let chatId):
                    ChatView(user: user, chatId: chatId)
                case .login:
                    LoginView(viewModel: viewModel, path: 
                }
            }

        }
        // Set up an authentication listener when the view appears
        .onAppear {
            viewModel.setupAuthListener()
        }
    }
}

#Preview {
    ContentView()
}
