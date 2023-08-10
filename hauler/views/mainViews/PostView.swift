//
//  PostView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//
import SwiftUI
import UIKit
import MapKit


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
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @Binding var rootScreen :RootView
    
    
    @State private var selectedImage: UIImage? = nil
    @State private var resizedImage: UIImage? = nil
    @State private var aspectMode: Bool = true
    
    @State private var alertTitle : String = ""
    @State private var alertMsg : String = ""
    @State private var alertIsPresented : Bool = false
    
    @FocusState private var isTitleFocused : Bool
    @State private var isTitleEditing : Bool = false{
        didSet{
            guard isTitleEditing != oldValue else {return}
            if(isTitleEditing){isDescEditing = false; isValueEditing = false}
            else{validateTitle()}
        }
    }
    @State private var isDescEditing : Bool = false{
        didSet{
            guard isDescEditing != oldValue else {return}
            if(isDescEditing){isTitleEditing = false; isValueEditing = false}
            else{validateDesc()}
        }
    }
    @State private var isValueEditing : Bool = false{
        didSet{
            guard isValueEditing != oldValue else {return}
            if(isValueEditing){isTitleEditing = false; isDescEditing = false}
            else{validateValue()}
        }
    }
    
    @State var titleValid = true {
        didSet {
            listingTitleHint = titleValid ? self.listingTitleHint : self.listingTitleError
        }
    }
    @State var descValid = true {
        didSet {
            listingDescHint = descValid ? self.listingDescHint : self.listingDescError
        }
    }
    @State var valueValid = true {
        didSet {
            listingValueHint = valueValid ? self.listingValueHint : self.listingValueError
        }
    }
    
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var listingController : ListingController
    //@EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var routeController : ViewRouter
    @EnvironmentObject var locationController : LocationManager
    
    @State private var isImagePickerPresented = false
    @State private var listing: Listing = Listing()
    
    @State private var listingTitle : String = ""
    @State private var listingDesc : String = ""
    @State private var listingValue : String = ""
    @State private var listingLoc : String = ""
    @State private var listingTitleHint = "Length 5 - 20"
    @State private var listingDescHint = "Length 5 - 100"
    @State private var listingValueHint = "0 < 999,999"
    @State private var listingTitleError = ""
    @State private var listingDescError = ""
    @State private var listingValueError = ""
    @State private var loc : CLLocation = CLLocation(latitude: 0, longitude: 0)
    
    @State private var useDefaultLocation : Bool = true
    @State private var nonCA : Bool = false
    @State private var showHint : Bool = false
    @FocusState private var focusedField : Fields?
    
    @State private var imageSourceType : ImagePickerView.ImageSourceType? = nil
    
    let delayController = DelayManager()
    
    var body: some View {
        VStack{
            if userProfileController.loggedInUserEmail != "" {
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
                                if selectedImage != nil{
                                    resizedImage = selectedImage!.resizePickedImage(aspectMode: aspectMode, size: 256)
                                }
                            })
                        } else {
                            VStack{
//                                Spacer()
                                Image(systemName: "plus.square")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color("HaulerOrange"))
//                                    .padding(.vertical, 100)
                                Text("Add Photo")
//                                Spacer()
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 30)
                            .onTapGesture {
                                openImagePicker()
                            }
                        }
                    }
                    
                    Section("Info"){
                        VStack{
                            MaterialDesignTextField($listingTitle, placeholder: "Title", hint: $listingTitleHint, editing: $isTitleEditing, valid: $titleValid, initialEditing: false)
                                .focused($focusedField, equals: .some(.title))
                                .onTapGesture {
                                    isTitleEditing = true
                                }
                            MaterialDesignTextField($listingDesc, placeholder: "Description", hint: $listingDescHint, editing: $isDescEditing, valid: $descValid, initialEditing: false)
                                .focused($focusedField, equals: .some(.desc))
                                .onTapGesture {
                                    isDescEditing = true
                                }
                            MaterialDesignTextField($listingValue, placeholder: "Price", hint: $listingValueHint, editing: $isValueEditing, valid: $valueValid, initialEditing: false)
                                .focused($focusedField, equals: .some(.price))
                                .onTapGesture {
                                    isValueEditing = true
                                }
                        }
                        .onChange(of: focusedField, perform: {which in
                            switch (which){
                            case .some(.title):
                                isTitleEditing = true
                            case .none:
                                clearFocus()
                            case .some(.desc):
                                isDescEditing = true
                            case .some(.price):
                                isValueEditing = true
                            case .some(.cate):
                                clearFocus()
                            case .some(.loca):
                                clearFocus()
                            }
                        })
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
                            .focused($focusedField, equals: .some(.cate))
                        }
                    }
                    
                    Section("Location"){
                        Picker("Where To Meet", selection: $useDefaultLocation, content: {
                            Text("Default").tag(true)
                            Text("Specfic").tag(false)
                        })
                        .pickerStyle(.segmented )
                        .focused($focusedField, equals: .some(.loca))
                        .onChange(of: useDefaultLocation, perform: {
                            if(!$0){
                                return
                            }
                            if(self.userProfileController.userProfile.uAddress == ""){
                                return
                            }
                            listingLoc = self.userProfileController.userProfile.uAddress
                            delayController.start(delay: 1, closure: {
                                self.locationController.ReversedLocation = listingLoc
                            })
                            
                            
                        })
                        .onChange(of: listingLoc, perform: {newloc in
                            var newaddr = newloc
                            if(!nonCA){
                                newaddr += ",Canada"
                            }
                            delayController.start(delay: 1, closure: {
                                
                                if(self.locationController.ReversedLocation != newaddr){
                                    showHint = true
                                }
                                self.locationController.ReversedLocation = newaddr
                                
                            })
                            
                        })
                        
                        HStack{
                            TextField("",text: $listingLoc)
                                .disabled(useDefaultLocation ? true : false)
                            if(!useDefaultLocation){
                                Toggle("Non CA", isOn: $nonCA)
                                    .buttonStyle(.borderedProminent)
                            }
                            
                        }
                        ZStack(alignment: .topLeading){
                            MapView(nb_location: CLLocation(latitude: self.locationController.latitude, longitude: self.locationController.longitude)).frame(height: 300)
                            if(!self.locationController.listOfReversedLocation.isEmpty){
                                if(showHint){
                                    ForEach(self.locationController.listOfReversedLocation, id: \.self){loc in
                                        HStack{
                                            Text(loc.name ?? "")
                                        }
                                        .onTapGesture {
                                            self.listingLoc = loc.name ?? ""
                                            showHint = false
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                    
                }
                .tint(Color("HaulerOrange"))
                .shadow(color: Color.gray.opacity(0.2), radius: 5, x:0, y:0)
                .scrollContentBackground(.hidden)
                
                
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
                .disabled(selectedImage == nil || !valueValid || !descValid || !titleValid)
            }
            else{
                Text("Oops, looks like you are not logged in!!")
                    .padding(.bottom, 0.5)
                    .font(.system(size: 20))
                Text("Log in to see your listings.")
                
                NavigationLink(destination: LoginView(rootScreen: $rootScreen).environmentObject(authController).environmentObject(userProfileController)) {
                    Text("Login")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                }
                .padding(.horizontal, 20)
                .padding([.top], 10)
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor(named: "HaulerOrange") ?? .blue))
                
                HStack {
                    Text("Don't have an account? ")
                    NavigationLink(destination: SignUpView(rootScreen: $rootScreen).environmentObject(authController).environmentObject(userProfileController)) {
                        Text("SignUp")
                            .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                            .fontWeight(.medium)
                    }
                }//HStack ends
                .padding([.top], 10)
            }
            
        }
        .onAppear{
            self.listingLoc = self.userProfileController.userProfile.uAddress
        }
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
    }
    func handleImagePickerDismissal() {
        if selectedImage == nil {
            // Image picker was dismissed without selecting an image
            print("Image picker dismissed without selecting an image.")
        } else {
            // Image picker was dismissed after selecting an image
            print("Image picker dismissed with selected image.")
            resizedImage = selectedImage!.resizePickedImage(aspectMode: aspectMode, size: 256)
        }
        imageSourceType = nil
        // Perform any additional handling as needed
    }
    
    func openImagePicker() {
        isImagePickerPresented = true
    }
    
    func clearFocus() {
        isTitleEditing = false
        isDescEditing = false
        isValueEditing = false
    }
    
    func saveListing() {
        guard titleValid && descValid && valueValid else{
            return
        }
        self.listing.email = self.userProfileController.loggedInUserEmail
        self.listing.title = self.listingTitle
        self.listing.desc = self.listingDesc
        self.listing.price = Double(self.listingValue)!
        self.listing.createDate = Date.now
        self.listing.available = true
        self.listing.locString = self.locationController.ReversedLocation
        self.listing.locLat = self.locationController.latitude
        self.listing.locLong = self.locationController.longitude
        listingController.insertListing(listing: listing)
        clearAfterListed()
    }
    
    func clearAfterListed() {
        self.listing = Listing()
        self.listingTitle = ""
        self.listingDesc = ""
        self.listingValue = ""
        self.selectedImage = nil
        self.resizedImage = nil
        self.clearFocus()
    }
    
    func validateTitle(){
        let copy = self.listingTitle
        if copy.isEmpty{
            self.titleValid = false
            self.listingTitleHint = validationErrorsTitle.Empty.desc
            return
        }
        if copy.count < 5{
            self.titleValid = false
            self.listingTitleHint = validationErrorsTitle.tooShort.desc
            return
        }
        if copy.count > 20{
            self.titleValid = false
            self.listingTitleHint = validationErrorsTitle.tooLong.desc
            return
        }
        self.titleValid = true
    }
    
    func validateDesc(){
        let copy = self.listingDesc
        if copy.isEmpty{
            self.descValid = false
            self.listingDescHint = validationErrorsDesc.Empty.desc
            return
        }
        if copy.count < 5{
            self.descValid = false
            self.listingDescHint = validationErrorsDesc.tooShort.desc
            return
        }
        if copy.count > 100{
            self.descValid = false
            self.listingDescHint = validationErrorsDesc.tooLong.desc
            return
        }
        self.descValid = true
    }
    
    func validateValue(){
        guard let copy = Double(self.listingValue) else{
            self.valueValid = false
            self.listingValueHint = validationErrorsValue.nan.desc
            return
        }
        if copy < 0{
            self.valueValid = false
            self.listingValueHint = validationErrorsValue.negative.desc
            return
        }
        if copy > 999999{
            self.valueValid = false
            self.listingValueHint = validationErrorsValue.tooBig.desc
            return
        }
        self.valueValid = true
    }
}


extension UIImage {
    func resizePickedImage(aspectMode: Bool, size: CGFloat) -> UIImage{
        var resizedImage : UIImage? = nil
        let targetedH : CGFloat = size
        let targetedW : CGFloat = size
        let targetedSize : CGSize = CGSize(width: targetedW, height: targetedH)
        var bgSize : CGSize? = nil
        UIGraphicsBeginImageContextWithOptions(targetedSize, true, 1.0)
        switch aspectMode{
        case true:
            let imgW = self.size.width
            let imgH = self.size.height
            let aspectRatio = imgW/imgH
            if aspectRatio > 1 {
                // Landscape image
                bgSize = CGSize(width: targetedW, height: targetedH / aspectRatio)
                self.draw(in: CGRect(origin: .init(x: 0, y: (targetedH - targetedH / aspectRatio) / 2), size: bgSize!))
                //                selectedImage!.draw(in: CGRect(origin: .zero, size: bgSize!))
            } else {
                // Portrait image
                bgSize = CGSize(width: targetedW * aspectRatio, height: targetedH)
                self.draw(in: CGRect(origin: .init(x: (targetedW - targetedW * aspectRatio) / 2, y: 0), size: bgSize!))
                //                selectedImage!.draw(in: CGRect(origin: .zero, size: bgSize!))
            }
            break
        case false:
            bgSize = CGSize(width: targetedW, height: targetedH)
            self.draw(in: CGRect(origin: .zero, size: bgSize!))
            break
        }
        defer{UIGraphicsEndImageContext()}
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        return resizedImage!
    }
}

//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView()
//    }
//}
