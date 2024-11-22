//
//  ProfileView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//


import SwiftUI
import FirebaseStorage


struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedImage: UIImage? = nil
    @State private var showingImagePicker: Bool = false

    var body: some View {
        VStack {
            if viewModel.isLoggedOut {
                Text("Redirecting to Login...")
                    .onAppear {
                        // Add navigation logic to log out and go back to login view
                    }
            } else {
                VStack(spacing: 20) {
                    //  use the Profile Image that was selected when current user registered
                    if let image = selectedImage ?? viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("Edit Image").foregroundColor(.gray))
                            .onTapGesture {
                                showingImagePicker = true
                            }
                    }

                    // Profile Details
                    Text("Name: \(viewModel.name)")
                        .font(.headline)
                    Text("Email: \(viewModel.email)")
                        .foregroundColor(.gray)

                    // to change and update the profile picture if needed
                    Button(action: {
                        if let selectedImage = selectedImage {
                            viewModel.updateProfileImage(selectedImage)
                        }
                    }) {
                        Text("Save Changes")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }

                    // Logout Button
                    Button(action: {
                        viewModel.logout()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .onAppear {
                    viewModel.fetchProfile()
                }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(selectedImage: $selectedImage) { image in
                        selectedImage = image
                    }
                }
            }
        }
    }
}


#Preview {
    ProfileView()
}
