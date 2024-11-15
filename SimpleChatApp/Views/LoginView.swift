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
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(spacing: 20){
                TextField(
                    "Enter email", text: $email)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.top, 20)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                
                Divider()
                
                SecureField(
                    "Enter Password",text: $password)
                .padding(.top, 20)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                Divider()
            }
            
            Spacer()
            
            Button {
                print("Login")
            } label: {
                Text("Login")
            }

            
            
                
        
               }
               .padding(30)
           }

}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
