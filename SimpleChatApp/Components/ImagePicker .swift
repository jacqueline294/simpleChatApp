//
//  ImagePicker .swift
//  SimpleChatApp
//
//  Created by jacqueline Ngigi on 2024-11-18.
//

import SwiftUI
import PhotosUI

struct PhotosPicker: View {
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }

            PhotosPicker
        }
    }
}
