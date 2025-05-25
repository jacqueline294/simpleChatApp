//
//  ChatView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-26.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject private var viewModel: ChatViewModel
    let user: User
    let chatId: String

    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var errorText: String = ""
    @State private var showError: Bool = false
    // Removed @State private var showStickerPanel: Bool = false
    @State private var showDocumentPicker: Bool = false // State for document picker
    @State private var selectedFileUrl: URL? = nil // Holds the URL of the selected file

    // Removed stickerIdentifiers array

    init(user: User, chatId: String) {
        self.user = user
        self.chatId = chatId
        _viewModel = StateObject(wrappedValue: ChatViewModel())
    }

    var body: some View {
        ZStack {
            // 🌈 Background
            LinearGradient(colors: [Color.teal.opacity(0.1), Color.indigo.opacity(0.15)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // 🧾 Messages
                if viewModel.messages.isEmpty {
                    Spacer()
                    Text("Start chatting with \(user.name)")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.messages) { message in
                                // Use MessageRow for displaying each message
                                MessageRow(message: message, isCurrentUser: message.senderId == Auth.auth().currentUser?.uid)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }

                // Removed Sticker Panel

                // 🧾 Input
                HStack(spacing: 12) {
                    // 📷 Image button
                    Button {
                        showingImagePicker = true
                        // Removed showStickerPanel = false
                        showDocumentPicker = false
                    } label: {
                        Image(systemName: "photo")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }
                    
                    // Removed Sticker Button
                    
                    // 📎 Document Picker Button
                    Button {
                        showDocumentPicker = true
                        showingImagePicker = false // Ensure other panels are hidden
                        // Removed showStickerPanel = false
                    } label: {
                        Image(systemName: "paperclip")
                            .foregroundColor(.blue)
                            .imageScale(.large)
                    }

                    // ✏️ Text input
                    TextField("Type a message...", text: $viewModel.newMessage, axis: .vertical)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .font(.subheadline)

                    // 🚀 Send
                    Button {
                        if viewModel.newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            // Optionally allow sending empty message if sticker panel is not the primary input
                            // For now, requires text if not sending sticker/image
                            errorText = "Message is empty."
                            showError = true
                        } else {
                            viewModel.sendMessage(toChat: chatId)
                        }
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) { _ in // Image is handled by the picker itself now
                if let image = self.selectedImage { // Use self.selectedImage
                    viewModel.sendImage(image, to: chatId)
                    self.selectedImage = nil // Reset after sending
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker(selectedURL: $selectedFileUrl, isPresented: $showDocumentPicker)
        }
        .onChange(of: selectedFileUrl) { newUrl in
            if let url = newUrl {
                // Ensure originalFileName is correctly extracted.
                // For files from DocumentPicker with asCopy=true, url.lastPathComponent should be the actual name.
                let originalFileName = url.lastPathComponent
                viewModel.sendFile(fileURL: url, originalFileName: originalFileName, toChat: chatId)
                selectedFileUrl = nil // Reset after processing
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorText)
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchMessages(forChat: chatId)
        }
    }
}

