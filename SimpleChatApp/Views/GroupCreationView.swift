//
//  GroupCreationView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroupCreationView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = InboxViewModel()
    @State private var selectedUserIds: Set<String> = []
    @State private var groupName: String = ""
    @Binding var path: [Destination]

    var body: some View {
        ZStack {
            // 🌈 Background
            LinearGradient(
                colors: [Color.mint.opacity(0.1), Color.teal.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Create New Group")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                // Group Name Input
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.blue)
                    TextField("Enter Group Name", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // User Selection
                List(viewModel.users) { user in
                    MultipleSelectionRow(
                        user: user,
                        isSelected: selectedUserIds.contains(user.id)
                    ) {
                        if selectedUserIds.contains(user.id) {
                            selectedUserIds.remove(user.id)
                        } else {
                            selectedUserIds.insert(user.id)
                        }
                    }
                    .listRowBackground(Color.white)
                }
                .listStyle(.insetGrouped)

                // Create Group Button
                Button(action: createGroup) {
                    Text("Create Group")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((groupName.isEmpty || selectedUserIds.isEmpty) ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(groupName.isEmpty || selectedUserIds.isEmpty)
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .onAppear {
            viewModel.fetchUsers()
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func createGroup() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user.")
            return
        }

        var members = Array(selectedUserIds)
        if !members.contains(currentUserId) {
            members.append(currentUserId)
        }

        let groupId = UUID().uuidString
        let group = Group(id: groupId, name: groupName, members: members)
        let db = Firestore.firestore()

        do {
            try db.collection("groups").document(groupId).setData(from: group) { error in
                if let error = error {
                    print("❌ Failed to create group: \(error.localizedDescription)")
                    return
                }

                // 🚨 Send a placeholder message to trigger listener setup
                let placeholderMessage: [String: Any] = [
                    "id": UUID().uuidString,
                    "text": "Welcome to \(group.name) 👋",
                    "senderId": currentUserId,
                    "timestamp": Timestamp(),
                    "imageUrl": NSNull(),
                    "groupId": groupId
                ]

                db.collection("groups")
                    .document(groupId)
                    .collection("messages")
                    .addDocument(data: placeholderMessage) { error in
                        if let error = error {
                            print("❌ Failed to write initial message: \(error.localizedDescription)")
                            return
                        }

                        // ✅ Navigate to GroupChat after initial message is saved
                        path.append(Destination(id: UUID(), type: .groupChat(group)))
                        dismiss()
                    }
            }
        } catch {
            print("❌ Error creating group: \(error.localizedDescription)")
        }
    }

}
