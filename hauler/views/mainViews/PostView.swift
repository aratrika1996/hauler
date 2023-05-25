//
//  PostView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//
import SwiftUI
import UIKit

extension UIImage {
    var sizeInBytes: Int {
        guard let cgImage = self.cgImage else {
            // This won't work for CIImage-based UIImages
            assertionFailure()
            return 0
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}

struct PostView: View {
    @State private var selectedImage: UIImage? = nil
    @State private var resizedImage: UIImage? = nil
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var listingController : ListingController
    
    @State private var isImagePickerPresented = false
    @State private var listing: Listing = Listing()
    @State private var aspectMode: Bool = true
    
    var body: some View {
            Form {
                Section {
                    if let image = resizedImage {
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                                .onTapGesture {
                                    isImagePickerPresented = true
                                }
                            Spacer()
                        }
                        Toggle(isOn: $aspectMode){
                            Text("Aspect Mode")
                        }.onChange(of: aspectMode, perform: {_ in
                            resizePickedImage(aspectMode: aspectMode)
                        })
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
                        guard let image = resizedImage else {
                            print("No image selected.")
                            return
                        }
                        listing.email = listingController.loggedInUserEmail
                        imageController.uploadImage(resizedImage!) { result in
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
            resizePickedImage(aspectMode: aspectMode)
        }
        // Perform any additional handling as needed
    }
    
    func resizePickedImage(aspectMode: Bool){
        guard let _ = selectedImage else{
            return
        }
        var resizedImage : UIImage? = nil
        let targetedH : CGFloat = 256
        let targetedW : CGFloat = 256
        let targetedSize : CGSize = CGSize(width: targetedW, height: targetedH)
        var bgSize : CGSize? = nil
        UIGraphicsBeginImageContextWithOptions(targetedSize, true, 1.0)
//        UIColor.white.setFill()
//        UIRectFill(CGRect(origin: .zero, size: targetedSize))
        switch aspectMode{
        case true:
            let imgW = (selectedImage?.size.width)!
            let imgH = (selectedImage?.size.height)!
            let aspectRatio = imgW/imgH
            if aspectRatio > 1 {
                // Landscape image
                bgSize = CGSize(width: targetedW, height: targetedH / aspectRatio)
                selectedImage!.draw(in: CGRect(origin: .init(x: 0, y: (targetedH - targetedH / aspectRatio) / 2), size: bgSize!))
//                selectedImage!.draw(in: CGRect(origin: .zero, size: bgSize!))
            } else {
                // Portrait image
                bgSize = CGSize(width: targetedW * aspectRatio, height: targetedH)
                selectedImage!.draw(in: CGRect(origin: .init(x: (targetedW - targetedW * aspectRatio) / 2, y: 0), size: bgSize!))
//                selectedImage!.draw(in: CGRect(origin: .zero, size: bgSize!))
            }
            break
        case false:
            bgSize = CGSize(width: targetedW, height: targetedH)
            selectedImage!.draw(in: CGRect(origin: .zero, size: bgSize!))
            break
        }
        defer{UIGraphicsEndImageContext()}
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        self.resizedImage = resizedImage
//        print("original byte: \(self.selectedImage?.sizeInBytes)")
//        print("resized byte: \(self.resizedImage?.sizeInBytes)")
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
