//
//  LoginView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var path: [Destination]
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack {
            // 🌈 Background gradient
            LinearGradient(
                colors: [Color.mint.opacity(0.15), Color.teal.opacity(0.2)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // 🖼 Logo from assets named "Chat Link"
                Image("Chat Link")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.top, 20)

                // 🟦 App name
                Text("ChitChat")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.blue)

                Text("Welcome Back")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)

                // 📨 Email input
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // 🔒 Password input
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // ❌ Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                // ✅ Login button
                Button(action: {
                    viewModel.login(email: email, password: password) { success, error in
                        if success {
                            path.append(Destination(id: UUID(), type: .profile))
                        } else {
                            errorMessage = error ?? "An unknown error occurred."
                        }
                    }
                }) {
                    Text("Login")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoginView(
        viewModel: AuthViewModel(),
        path: .constant([])
    )
}
