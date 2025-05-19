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
        VStack(spacing: 20) {
            
            Image("Talk")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
                .padding(.bottom)
           
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: {
                viewModel.login(email: email, password: password) { success, error in
                    if success {
                        // Navigate to Profile after successful login
                        path.append(Destination(id: UUID(), type: .profile))
                    } else {
                        errorMessage = error ?? "An unknown error occurred."
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView(
        viewModel: AuthViewModel(),
        path: .constant([])
    )
}
