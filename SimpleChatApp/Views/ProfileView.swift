//
//  ProfileView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//


import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @Binding var path: [Destination]

    var body: some View {
        ZStack {
            // 🌈 Background
            LinearGradient(
                colors: [Color.mint.opacity(0.1), Color.teal.opacity(0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 30) {
                // 🧠 App Logo or Title
                Image("Chat Link")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(.top, 20)

                // 👤 Profile Card
                VStack(spacing: 12) {
                    if let image = profileViewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("No Image").foregroundColor(.gray))
                    }

                    Text(profileViewModel.name)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(profileViewModel.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    if profileViewModel.isLoading {
                        ProgressView()
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 4)
                .padding(.horizontal)

                // 📬 Go to Inbox Button
                Button(action: {
                    path.append(Destination(id: UUID(), type: .inbox))
                }) {
                    Text("Go to Inbox")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // 🚪 Logout Button
                Button(action: {
                    authViewModel.logout()
                    path = []
                }) {
                    Text("Logout")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top)
        }
        .onAppear {
            profileViewModel.fetchProfile()
        }
    }
}

#Preview {
    ProfileView(path: .constant([]))
        .environmentObject(AuthViewModel())
}
