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
    @StateObject private var viewModel = InboxViewModel() // Reuse this to load users
    @State private var selectedUserIds: Set<String> = []
    @State private var groupName: String = ""
    @Binding var path: [Destination]

    var body: some View {
        VStack {
            TextField("Group Name", text: $groupName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            List(viewModel.users) { user in
                MultipleSelectionRow(user: user, isSelected: selectedUserIds.contains(user.id)) {
                    if selectedUserIds.contains(user.id) {
                        selectedUserIds.remove(user.id)
                    } else {
                        selectedUserIds.insert(user.id)
                    }
                }
            }


            Button("Create Group") {
                createGroup()
            }
            .disabled(groupName.isEmpty || selectedUserIds.isEmpty)
            .padding()
        }
        .navigationTitle("New Group")
        .onAppear {
            viewModel.fetchUsers()
        }
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
