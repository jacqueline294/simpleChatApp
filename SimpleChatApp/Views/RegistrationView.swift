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
    @State private var selectedImage: UIImage? = nil
    @State private var profileImage: Image? = nil
    @State private var isPickerPresented: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Chit Chat")
                .font(.largeTitle)
                .bold()

            Image("Talk")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
            
            Text("Sign up to chat with friends")

            // Profile Picture Picker
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .padding()
            } else {
                Button(action: {
                    isPickerPresented = true
                }) {
                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                        Text("Add Profile Picture")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                .padding()
            }

            // Registration Fields
            TextField("Enter Full Name", text: $name)
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

            // Sign Up Button
            Button(action: {
                guard !name.isEmpty else {
                    errorMessage = "Please enter your full name"
                    return
                }

                viewModel.signUp(email: email, password: password, name: name, profileImage: selectedImage) { success, error in
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
        .sheet(isPresented: $isPickerPresented) {
            ImagePicker(selectedImage: $selectedImage, onImagePicked: { image in
                profileImage = Image(uiImage: image)
                selectedImage = image
            })
        }
    }
}


#Preview {
    RegistrationView(
        viewModel: AuthViewModel(),
                path: .constant([]) 
    )
}
