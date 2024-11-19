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

            
            }
            
            Spacer()
        }
       
    }



#Preview {
    InboxView(
        viewModel: AuthViewModel(),
                path: .constant([]) 
    )
}
