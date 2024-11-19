//
//  LoginView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import Combine

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var path: [String] // To manage navigation
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            
            Text("Chit Chat stay connected ")
                .font(.largeTitle)
                .bold()
                
            Image("Talk")
            
            Text("Login")
                .font(.subheadline)
                .bold()
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
            }

            Button(action: {
                viewModel.login(email: email, password: password) { success, error in
                    if success {
                        path.append("inboxView") // Navigate to inboxView 
                    } else {
                        errorMessage = error ?? "An unknown error occurred"
                    }
                }
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Log In")
    }
}


#Preview {
    LoginView(
        viewModel: AuthViewModel(),
                path: .constant([]) 
    )
}
