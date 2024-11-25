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
    @State private var path: [String] = [] // Holds the navigation stack state

    var body: some View {
        NavigationStack(path: $path) {
            
    if viewModel.user == nil {
    RegistrationView(viewModel: viewModel, path: $path)
    .navigationDestination(for: String.self) { destination in
        switch destination {
        case "Login":
        LoginView(viewModel: viewModel, path: $path)
        case "Inbox":
            InboxView()
            default:
            EmptyView()
        }
    }
            } else {
                ProfileView(authViewModel: viewModel)
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
