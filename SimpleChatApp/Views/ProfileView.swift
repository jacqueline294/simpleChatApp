//
//  ProfileView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Picture
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                }
                Button("Pick Profile Picture") {
                    viewModel.showingImagePicker = true
                }

                // User Info
                Text(viewModel.name)
                    .font(.headline)
                Text(viewModel.email)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                // Navigation to Inbox
                NavigationLink(destination: InboxView(), isActive: $viewModel.navigateToInbox) {
                    Button("Go to Inbox") {
                        viewModel.navigateToInbox = true
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                // Logout Button
                Button("Log Out") {
                    viewModel.logOut()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationBarTitle("Profile", displayMode: .inline)
            .onAppear {
                viewModel.loadUserInfo()
            }
            .sheet(isPresented: $viewModel.showingImagePicker) {
                PhotosPicker
            }
        }
        
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text("OK")))
        }
    }
}


#Preview {
    ProfileView()
}
