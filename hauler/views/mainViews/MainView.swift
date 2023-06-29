//
//  MainView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

struct MainView: View {
    @Environment(\.scenePhase) var scenePhase
    
    private let authController : AuthController;
    private let listingController : ListingController;
    private let userProfileController : UserProfileController;
    private let imageController : ImageController;
    private let chatContoller : ChatController;
    private let locationController : LocationManager
    @State private var isLoading : Bool = true
    @State private var root : RootView = .HOME
    @State private var keycount : Int = 0
    @ObservedObject var pageController = ViewRouter()
    
    
    
    init(){
        authController = AuthController()
        listingController = ListingController(store: Firestore.firestore())
        userProfileController = UserProfileController(store: Firestore.firestore())
        imageController = ImageController()
        chatContoller = ChatController()
        locationController = LocationManager()
    }
    
    var body: some View {
        NavigationStack(){
            if(!isLoading){
                switch root{
                case .HOME:
                    ContentView(rootScreen : $root)
                    
                case .LOGIN:
                    LoginView(rootScreen : $root)
                    
                case .SIGNUP:
                    SignUpView(rootScreen : $root)
                    
                }
            }else{
                SplashScreenView()
            }
            
        }
        .onAppear{
            UITabBar.appearance().backgroundColor = UIColor(named: "BackgroundGray") ?? .white
            if let email = UserDefaults.standard.value(forKey: "KEY_EMAIL"){
                self.userProfileController.getAllUserData(completion: {})
            }
            if(self.chatContoller.chatRef == nil){
                chatContoller.fetchChats(completion: {keys in
                    print("after main appear, chat profile = \(self.chatContoller.chatDict.count)")
                    keycount = 0
                    if !keys.isEmpty{
                        keys.forEach{
                            userProfileController.getUserByEmail(email: $0, completion: {_,success in
                                if(success){
                                    keycount += 1
                                    print("now keycount= \(keycount)")
                                    if(keycount == keys.count){
                                        isLoading = false
                                        keycount = 0
                                    }
                                }
                            })
                        }
                    }else{
                        isLoading = false
                    }
                })
            }else{
                isLoading = false
            }
        }
//NavigationView
        .onChange(of: scenePhase){currentPhase in
            switch(currentPhase){
            case .active:
                print("active")

            case .inactive:
                print("inactive")
            case .background:
                print("background")
                chatContoller.chatRef?.remove()
//                if userProfileController.userProfile.uEmail != ""{
//                    let userProfile = userProfileController.userProfile
//                    do{
//                        let encodedJson = try JSONEncoder().encode(userProfile)
//                        print("Saving \(userProfile) @background")
//                        UserDefaults.standard.set(encodedJson, forKey: userProfile.uEmail)
//                    }catch{
//                        print("JSON ENCODE ERROR @ saving user, inactive\(error)")
//                    }
//                }
            @unknown default:
                fatalError()
            }
//
//
        }
        
        .navigationViewStyle(.stack)
        .environmentObject(pageController)
        .environmentObject(authController)
        .environmentObject(listingController)
        .environmentObject(imageController)
        .environmentObject(userProfileController)
        .environmentObject(chatContoller)
        .environmentObject(locationController)
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
