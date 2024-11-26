//
//  ProfileView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel // Handles logout and user state
    @StateObject private var profileViewModel = ProfileViewModel() // Manages profile data
    @Binding var path: [Destination] // Use binding to update the main navigation stack

    var body: some View {
        VStack(spacing: 20) {
            // Profile Image Section
            if let image = profileViewModel.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(Text("No Image").foregroundColor(.gray))
            }

            // Profile Details
            Text(profileViewModel.name)
                .font(.title)

            Text(profileViewModel.email)
                .foregroundColor(.gray)

            // Loading Indicator
            if profileViewModel.isLoading {
                ProgressView()
            }

            // Navigation to Inbox
            Button("Go to Inbox") {
                path.append(Destination(id: UUID(), type: .inbox))
            }
            .buttonStyle(.bordered)

            // Logout Button
            Button("Logout") {
                authViewModel.logout()
            }
            .foregroundColor(.red)
        }
        .padding()
        .onAppear {
            profileViewModel.fetchProfile()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(authViewModel: AuthViewModel(), path: .constant([]))
    }
}


