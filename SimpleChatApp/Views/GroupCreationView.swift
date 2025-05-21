//
//  GroupCreationView.swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2025-05-19.
//

import SwiftUI
import FirebaseFirestore

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
                // 🧠 Title
                Text("Create New Group")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                // ✏️ Group Name Field
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.blue)
                    TextField("Enter Group Name", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // 🧑‍🤝‍🧑 User Selection
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

                // ✅ Create Button
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
        let groupId = UUID().uuidString
        let group = Group(id: groupId, name: groupName, members: Array(selectedUserIds))

        let db = Firestore.firestore()
        do {
            try db.collection("groups").document(groupId).setData(from: group)
            path.append(Destination(id: UUID(), type: .groupChat(group)))
            dismiss()
        } catch {
            print("❌ Failed to create group:", error.localizedDescription)
        }
    }
}
