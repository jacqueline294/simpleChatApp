//
//  RegistrationView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var path: [String]
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker: Bool = false // Use local state

    var body: some View {
        VStack(spacing: 20) {
            Text("Create an Account")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Profile Image Picker
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(Text("Add Image").foregroundColor(.gray))
                    .onTapGesture {
                        showingImagePicker = true
                    }
            }

            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
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
                signUp()
            }) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                selectedImage = image
            }
        }
    }

    private func signUp() {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            errorMessage = "All fields are required."
            return
        }

        viewModel.signUp(email: email, password: password, name: name, profileImage: selectedImage) { success, error in
            if success {
                path.append("Inbox")
            } else {
                errorMessage = error ?? "Registration failed."
            }
        }
    }
}


#Preview {
    RegistrationView(
        viewModel: AuthViewModel(),
                path: .constant([]) 
    )
}
