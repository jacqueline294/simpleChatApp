//
//  ProfileViewModel.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-15.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

class ProfileViewModel: ObservableObject {
    @Published var profileImage: Image? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
}


