//
//  RegistrationView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var path: [String] // To manage navigation
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Chit chat")
                .font(.largeTitle)
                .bold()
            
            Image ("Talk")
                .font(.subheadline)
                .bold()
            
            Text("Sign up to chat with friends")
            
            TextField("Enter FullName", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Enter Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Enter Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: {
                viewModel.signUp(email: email, password: password) { success, error in
                    if success {
                        path.append("Inbox") // Navigate to InboxView
                    } else {
                        errorMessage = error ?? "An unknown error occurred"
                    }
                }
            }) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button("Already have an account? Log In") {
                path.append("Login") // Navigate to LoginView
            }
            .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Register")
    }
}


#Preview {
    RegistrationView(
        viewModel: AuthViewModel(),
                path: .constant([]) 
    )
}
