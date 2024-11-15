//
//  InboxView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct InboxView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Binding var path: [String] // To manage navigation

    var body: some View {
        VStack {
            Text("Welcome to your Inbox")
                .font(.largeTitle)
                .bold()
            
            Image(systemName: "person.circle.fill")

            VStack {
                Button("Log Out") {
                    viewModel.logout()
                    path.removeAll() // Clear the navigation stack on logout
                }
                .foregroundColor(.red)
                .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Inbox")
    }
}


#Preview {
    InboxView(
        viewModel: AuthViewModel(),
                path: .constant([]) 
    )
}
