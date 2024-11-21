//
//  ProfileView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore



struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel() // Use your ProfileViewModel

    var body: some View {
        VStack {
            if viewModel.isLoggedOut {
                // Handle navigation to login view
                Text("Redirecting to Login...")
                    .onAppear {
                        // Navigation logic to LoginView
                        print("User is logged out, navigate to login view.")
                    }
            } else if viewModel.name == "Loading..." && viewModel.email == "Loading..." {
                // Show loading spinner
                ProgressView("Loading Profile...")
                    .padding()
            } else {
                VStack {
                    // Profile Picture
                    if let image = viewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .padding()
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                            .padding()
                    }

                    // Upload Button for Profile Picture
                    Button(action: {
                        viewModel.showingImagePicker = true
                    }) {
                        Text("Change Profile Picture")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.bottom)

                    // User Information
                    Text(viewModel.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)

                    Text(viewModel.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom)

                    Spacer()

                    // Sign Out Button
                    Button(action: {
                        viewModel.logOut()
                    }) {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchUserProfile()
        }
        .alert(item: $viewModel.alertItem) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: .constant(nil)) { image in
                viewModel.uploadProfilePicture(image)
            }
        }
        .navigationTitle("Profile")
    }
}


#Preview {
    ProfileView()
}
