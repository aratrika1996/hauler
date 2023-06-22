//
//  ProfileView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var pageController : ViewRouter
    
    @State private var name : String = ""
    @State private var email : String = ""
    
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage? = nil
    @State private var imageSourceType : ImagePickerView.ImageSourceType? = nil
    
    @Binding var rootScreen :RootView
    
    var body: some View {
        VStack {
            if userProfileController.loggedInUserEmail != "" {
                Form {
                    Section {
                        HStack(alignment: .center) {
                            ZStack(alignment: .bottomTrailing) {
                                if selectedImage != nil {
                                    Image(uiImage: selectedImage!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                        .scaledToFit()
                                }
                                else {
                                    Image(systemName: "person")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.black)
                                        .padding(30)
                                        .background(Color.gray)
                                        .clipShape(Circle())
                                }
                                
                                Image("Camera")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.black)
                                    .onTapGesture(perform: {
                                        isImagePickerPresented = true
                                    })
                            }
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
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .buttonStyle(BorderlessButtonStyle())
                                        Button("Browse Library"){
                                            self.imageSourceType = .photoLibrary
                                            ImagePickerView(isPresented: $isImagePickerPresented, imageSourceType: $imageSourceType,selectedImage: $selectedImage)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.horizontal, 50)
                                    .presentationDetents([.height(130)])
                                    
                                }
                            }
                            VStack(alignment: .leading) {
                                Text(self.name)
                                    .foregroundColor(Color(UIColor(named: "HaulerOrange") ?? .blue))
                                    .font(.system(size: 22))
                                    .fontWeight(.medium)
                                    .padding(.bottom, 0.3)
                                Text(self.email)
                                    .padding(.bottom, 0.3)
//                                HStack {
//                                    Image(systemName: "star.fill")
//                                        .resizable()
//                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(Color.yellow)
//                                    Image(systemName: "star.fill")
//                                        .resizable()
//                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(Color.yellow)
//                                    Image(systemName: "star.fill")
//                                        .resizable()
//                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(Color.yellow)
//                                    Image(systemName: "star.fill")
//                                        .resizable()
//                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(Color.yellow)
//                                    Image(systemName: "star.fill")
//                                        .resizable()
//                                        .frame(width: 20, height: 20)
//                                        .foregroundColor(Color.yellow)
//                                    Text("5.0")
//                                    Text("(8)")
//                                }
                                Text("+1\(self.userProfileController.userProfile.uPhone)")
                            }
                            .padding(.leading, 10)
                        }//HStack ends
                    }
                    .listRowBackground(Color.white.opacity(0))
                    .listRowInsets(EdgeInsets())
                    
                    Section(header: Text("Profile details")) {
                        NavigationLink(destination: PersonalDetailsView().environmentObject(userProfileController)) {
                            Text("Personal details")
                        }
                    }
                    
                    Section(header: Text("Account settings")) {
                        NavigationLink(destination: ManageAccountView(rootScreen: $rootScreen).environmentObject(userProfileController).environmentObject(authController).environmentObject(listingController)) {
                            Text("Manage account")
                        }
                        Text("Notification preferences")
                    }
                    
                    Section(header: Text("General information")) {
                        Text("Terms of use")
                        Text("Privacy policy")
                        Text("Help")
                    }
                    
                    Section(header: Text("Display settings")) {
                        Text("App theme")
                    }
                    
                    Section {
                        
                        Button(action: {
                            authController.signOut()
                            userProfileController.updateLoggedInUser()
                            userProfileController.loggedInUserEmail = ""
                            userProfileController.userProfile = UserProfile()
                            userProfileController.userDict = [:]
                            chatController.chatDict = [:]
                            pageController.currentView = .main
                            
                            
                        }){
                            Text("Log out")
                                .font(.system(size: 20))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color.white)
                            
                        }//Button ends
                    }
                    .listRowBackground(Color(UIColor(named: "HaulerOrange") ?? .blue))
                }
            }
            else {
                Text("Oops, looks like you are not logged in!!")
                    .padding(.bottom, 0.5)
                    .font(.system(size: 20))
                Text("Log in to manage your profile.")
                
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
        .onAppear {
            self.userProfileController.getAllUserData {
                print("data retrieved")
                self.name = self.userProfileController.userProfile.uName
                if let email = UserDefaults.standard.value(forKey: "KEY_EMAIL"){
                    self.email = email as! String
                }else{
                    self.email = ""
                }
                self.loadImage(from: self.userProfileController.userProfile.uProfileImageURL ?? "")
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
            imageController.uploadImage(selectedImage!) {result in
                switch result {
                case .success(let url):
                    // Handle the success case with the URL
                    print("Image uploaded successfully. URL: \(url)")
                    // Once we get the URL, we can update the imageURI field in the listing
                    self.userProfileController.updateUserProfileImage(imageURLToUpdate: url.absoluteString) {_ in 
                        print("Image uploaded")
                    }
                    
                case .failure(let error):
                    // Handle the error case
                    print("Error uploading image: \(error)")
                    
                }
            }
            //resizePickedImage(aspectMode: aspectMode)
        }
        imageSourceType = nil
        // Perform any additional handling as needed
    }
    
    func loadImage(from urlString: String) {
            guard let url = URL(string: urlString) else {
                // Handle invalid URL
                return
            }

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    // Handle error during image loading
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }

                if let imageData = data, let loadedImage = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.selectedImage = loadedImage
                    }
                }
            }.resume()
        }
}

//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
