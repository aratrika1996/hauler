//
//  PostView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//
import SwiftUI
import UIKit

struct PostView: View {
    @State private var selectedImage: UIImage? = nil
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var listingController : ListingController
    
    @State private var isImagePickerPresented = false
    @State private var listing: Listing = Listing()
    
    var body: some View {
            Form {
                Section {
                    if let image = selectedImage {
                        VStack {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 200)
                            Spacer()
                        }
                    } else {
                        Button(action: openImagePicker) {
                            Text("Select Image")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Section {
                    TextField("Title", text: $listing.title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description", text: $listing.desc)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Price", value: $listing.price, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    HStack {
                        Text("Category")
                        Picker(selection: $listing.category, label: Text("")) {
                            ForEach(ListingCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section {
                    Button(action: {
                        guard let image = selectedImage else {
                            print("No image selected.")
                            return
                        }
                        
                        imageController.uploadImage(image) { result in
                            switch result {
                            case .success(let url):
                                // Handle the success case with the URL
                                print("Image uploaded successfully. URL: \(url)")
                                // Once we get the URL, we can update the imageURI field in the listing
                                listing.imageURI = url.absoluteString
                                
                                // Perform any additional operations with the completed listing
                                saveListing()
                            case .failure(let error):
                                // Handle the error case
                                print("Error uploading image: \(error)")
                            }
                        }
                    }) {
                        Text("Post Listing")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedImage == nil ? Color.gray : Color.green)
                            .cornerRadius(10)
                    }
                    .disabled(selectedImage == nil)
                }
            }
            .navigationBarTitle("Post Listing")
            .padding()
            .sheet(isPresented: $isImagePickerPresented, onDismiss: handleImagePickerDismissal) {
                ImagePickerView(isPresented: $isImagePickerPresented, selectedImage: $selectedImage)
            }
    }
    
    func handleImagePickerDismissal() {
        if selectedImage == nil {
            // Image picker was dismissed without selecting an image
            print("Image picker dismissed without selecting an image.")
        } else {
            // Image picker was dismissed after selecting an image
            print("Image picker dismissed with selected image.")
        }
        // Perform any additional handling as needed
    }


    
    func openImagePicker() {
        isImagePickerPresented = true
    }
    
    func saveListing() {
        listingController.insertListing(listing: listing)
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
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
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
