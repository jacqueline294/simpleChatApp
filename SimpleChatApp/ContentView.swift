//
//  ContentView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var ViewModel = AuthViewModel()
    
    var body: some View {
        VStack{
            switch ViewModel.currentState {
            case.registration:
                RegistrationView(viewModel: ViewModel)
            
            case.login:
                LoginView(viewModel: ViewModel)
            
            case.inbox:
                InboxView(viewModel: ViewModel)
            
            case.profile:
                ProfileView(viewModel: ViewModel)
                
            }
            
        }
    }
}

#Preview {
    ContentView()
}
