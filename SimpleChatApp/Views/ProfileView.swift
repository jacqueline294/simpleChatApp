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
    @State private var isPickerPresented = false

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
                    isPickerPresented = true
                }
                .sheet(isPresented: $isPickerPresented) {
                    ImagePicker(selectedImage: $viewModel.profileImage)
                }

                if let user = viewModel.user {
                                    Text("Email: \(user.email ?? "N/A")")
                                    Button("Log Out") {
                                viewModel.logOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
        
    }
}


#Preview {
    ProfileView()
}
