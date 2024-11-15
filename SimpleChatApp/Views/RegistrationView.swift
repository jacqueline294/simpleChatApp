//
//  RegistrationView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel : AuthViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Text("Registration")
                .font(.headline)
                .padding()
            
            TextField("Email", text: $email)
                .padding()
            
            SecureField("Password", text: $password)
            Button(action: {
                viewModel.Register(email: email, password: password)
            }) {
                Text("Register")
            }
        }
    }
}

#Preview {
    RegistrationView(viewModel: AuthViewModel())
}
