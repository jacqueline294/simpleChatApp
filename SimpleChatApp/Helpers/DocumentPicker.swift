import SwiftUI
import UniformTypeIdentifiers // Required for UTType

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var selectedURL: URL?
    @Binding var isPresented: Bool // To control the presentation state from ChatView

    // Define the types of documents that can be picked
    // For PDF and Word documents
    let supportedTypes: [UTType] = [UTType.pdf, UTType.word, UTType(filenameExtension: "doc")!].compactMap { $0 }


    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Pass `false` to `forOpeningContentTypes` to allow selecting multiple files if needed,
        // but for this task, single selection is implied.
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        controller.delegate = context.coordinator
        controller.allowsMultipleSelection = false // Explicitly set to false
        return controller
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No specific updates needed here for this implementation
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                parent.isPresented = false // Dismiss if no URL is selected
                return
            }
            // The file is copied to a temporary directory by the picker.
            // We need to ensure we can access it.
            // Security-scoped access might be needed if the URL is outside the app's sandbox.
            // However, 'asCopy: true' usually places it in a temporary directory accessible to the app.
            if url.startAccessingSecurityScopedResource() {
                parent.selectedURL = url // Pass the URL back
                // Note: stopAccessingSecurityScopedResource() should be called when done with the file.
                // This will be handled by ChatViewModel after upload.
            } else {
                print("Could not access security-scoped resource for URL: \(url.path)")
                // Handle error, perhaps by showing an alert to the user.
                parent.selectedURL = nil // Clear any previously selected URL
            }
            parent.isPresented = false // Dismiss the picker
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled.")
            parent.selectedURL = nil // Clear any selection
            parent.isPresented = false // Dismiss the picker
        }
    }
}
