//
//  RegistrationView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct RegistrationView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var path: [Destination]
    @State private var email: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker: Bool = false

    var body: some View {
        ZStack {
            //  Gradient background
            LinearGradient(
                colors: [Color.teal.opacity(0.1), Color.mint.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // 🖼 App Logo from Assets
                Image("Chat Link")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)
                    .padding(.top, 20)

                // 🟦 App Name
                Text("ChitChat")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.blue)

                // 👤 Profile Image Picker
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

                // 📝 Input Fields
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // ❌ Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                // ✅ Sign Up Button
                Button(action: {
                    viewModel.signUp(email: email, password: password, name: name, profileImage: selectedImage) { success, error in
                        if success {
                            path.append(Destination(id: UUID(), type: .inbox))
                        } else if let error = error {
                            errorMessage = error
                        }
                    }
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                Spacer()

                // 🔁 Switch to Login
                Button(action: {
                    path.append(Destination(id: UUID(), type: .login))
                }) {
                    Text("Already have an account? Log In")
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { image in
                selectedImage = image
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
