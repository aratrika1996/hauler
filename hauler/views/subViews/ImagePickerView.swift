//
//  ImagePickerView.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-15.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var imageSourceType: ImageSourceType?
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        switch imageSourceType{
        case .photoLibrary:
            imagePickerController.sourceType = .photoLibrary
        case .camera:
            imagePickerController.sourceType = .camera
        case .none:
            imagePickerController.sourceType = .photoLibrary
        }
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed
    }
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(parent: ImagePickerView) {
            self.parent = parent
        }
        
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.isPresented = false
        }
        
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
    
    enum ImageSourceType: Int {
            case photoLibrary
            case camera
        }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(isPresented: .constant(true), imageSourceType: .constant(.photoLibrary), selectedImage: .constant(nil))
    }
}
