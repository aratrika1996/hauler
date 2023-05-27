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
    private let authController : AuthController;
    private let listingController : ListingController;
    private let userProfileController : UserProfileController;
    private let imageController : ImageController;
    private let chatContoller : ChatController;
    @State private var root : RootView = .HOME
    
    
    init(){
        authController = AuthController()
        listingController = ListingController(store: Firestore.firestore())
        userProfileController = UserProfileController(store: Firestore.firestore())
        imageController = ImageController()
        chatContoller = ChatController()
    }
    
    var body: some View {
        NavigationView{
            switch root{
            case .HOME:
                ContentView(rootScreen : $root).environmentObject(authController).environmentObject(listingController).environmentObject(imageController).environmentObject(userProfileController).environmentObject(chatContoller)
                
            }
        }//NavigationView
        .navigationViewStyle(.stack)
        .navigationBarBackButtonHidden(true)
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
