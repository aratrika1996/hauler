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
    @State private var aspectMode: Bool = true
    
    @State private var alertTitle : String = ""
    @State private var alertMsg : String = ""
    @State private var alertIsPresented : Bool = false
    
    @State private var isTitleEditing : Bool = false{
        didSet{
            guard isTitleEditing != oldValue else {return}
            if(isTitleEditing){isDescEditing = false; isValueEditing = false}
        }
    }
    @State private var isDescEditing : Bool = false{
        didSet{
            guard isDescEditing != oldValue else {return}
            if(isDescEditing){isTitleEditing = false; isValueEditing = false}
        }
    }
    @State private var isValueEditing : Bool = false{
        didSet{
            guard isValueEditing != oldValue else {return}
            if(isValueEditing){isTitleEditing = false; isDescEditing = false}
        }
    }
    
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var routeController : ViewRouter
    
    @State private var isImagePickerPresented = false
    @State private var listing: Listing = Listing()
    
    @State private var listingTitle : String = ""
    @State private var listingDesc : String = ""
    @State private var listingValue : String = ""
    
    @State private var useDefaultLocation : Bool = true
    
    
    @State private var imageSourceType : ImagePickerView.ImageSourceType? = nil
    
    var body: some View {
        VStack{
            Form {
                Section("Photo") {
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
                            HStack{
                                Spacer()
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .frame(width: 70, height: 70)
                                    
                                    .padding(.vertical, 100)
                                Spacer()
                            }
                            .onTapGesture {
                                openImagePicker()
                            }
                    }
                }
                
                Section ("Info"){
                    VStack{
                        MaterialDesignTextField($listingTitle, placeholder: "Title", editing: $isTitleEditing)
                            .onTapGesture {
                                isTitleEditing = true
                            }
                        MaterialDesignTextField($listingDesc, placeholder: "Description", editing: $isDescEditing)
                            .onTapGesture {
                                isDescEditing = true
                            }
                        MaterialDesignTextField($listingValue, placeholder: "Price", editing: $isValueEditing)
                            .onTapGesture {
                                isValueEditing = true
                            }
                    }
                    
                }
                
                .onTapGesture {
                    isTitleEditing = false
                    isDescEditing = false
                    isValueEditing = false
                }
                Section("Detail"){
                    HStack{
                        Text("Category")
                        Picker(selection: $listing.category, label: Text("")) {
                            ForEach(ListingCategory.allCases, id: \.self) { category in
                                Text(category.displayName).tag(category)
                                    
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Location"){
                    Picker("Where To Meet", selection: $useDefaultLocation, content: {
                        Text("Default").tag(true)
                        Text("Specfic").tag(false)
                    })
                    .pickerStyle(.segmented )
                }
                    
                
            }
            .tint(Color("HaulerOrange"))
            .shadow(radius: 5)
//            .background(Color("HaulerOrangeLite"))
            .scrollContentBackground(.hidden)
            .navigationBarTitle("Post Listing")
            .alert(self.alertTitle, isPresented: $alertIsPresented, actions: {
                Button("OK"){
                    self.routeController.currentView = .post
                }
            }, message: {Text(self.alertMsg)})
            .sheet(isPresented: $isImagePickerPresented, onDismiss: handleImagePickerDismissal) {
                if($imageSourceType.wrappedValue != nil){
                    ImagePickerView(isPresented: $isImagePickerPresented, imageSourceType: $imageSourceType,selectedImage: $selectedImage)
                }else{
                    VStack{
                        Button("Take Photo"){
                            self.imageSourceType = .camera
                            ImagePickerView(isPresented: $isImagePickerPresented, imageSourceType: $imageSourceType,selectedImage: $selectedImage)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("HaulerOrangeLite"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                        Button("Browse Library"){
                            self.imageSourceType = .photoLibrary
                            ImagePickerView(isPresented: $isImagePickerPresented, imageSourceType: $imageSourceType,selectedImage: $selectedImage)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("HaulerOrangeLite"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .padding(.horizontal, 50)
                    .presentationDetents([.height(130)])
                }
                
            }
            Button(action: {
                guard let _ = resizedImage else {
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
                        self.alertTitle = "Success"
                        self.alertMsg = "PostSuccess"
                        
                    case .failure(let error):
                        // Handle the error case
                        print("Error uploading image: \(error)")
                        self.alertTitle = "Failed"
                        self.alertMsg = "PostFailed"
                    }
                    alertIsPresented = true
                    
                }
            }) {
                Text("Post Listing")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedImage == nil ? Color.gray : Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 10)
            .disabled(selectedImage == nil)
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
        imageSourceType = nil
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
    }


    
    func openImagePicker() {
        isImagePickerPresented = true
    }
    
    func saveListing() {
        self.listing.title = self.listingTitle
        self.listing.desc = self.listingDesc
        self.listing.price = Double(self.listingValue)!
        self.listing.createDate = Date.now
        self.listing.available = true
        listingController.insertListing(listing: listing)
        clearAfterListed()
    }
    
    func clearAfterListed() {
        self.listing = Listing()
        self.listingTitle = ""
        self.listingDesc = ""
        self.listingTitle = ""
        self.selectedImage = nil
        self.resizedImage = nil
    }
}

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

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
