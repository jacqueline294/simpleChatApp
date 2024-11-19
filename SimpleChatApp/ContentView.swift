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
                // If the user is not logged in, show RegistrationView
                RegistrationView(viewModel: viewModel, path: $path)
                    .navigationDestination(for: String.self) { destination in
                        if destination == "Login" {
                            LoginView(viewModel: viewModel, path: $path)
                        }
                    }
            } else {
                // If the user is logged in, show InboxView
                InboxView(viewModel: viewModel, path: $path)
            }
        }
        .onAppear {
            // Automatically update the user state when the view appears
            viewModel.user = Auth.auth().currentUser
        }
    }
}

#Preview {
    ContentView()
}
