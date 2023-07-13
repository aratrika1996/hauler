//
//  ContentView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

enum page:Int{
    case Home = 1, Chats = 2, Posts = 3, Listings = 4, Profile = 5
    var name: String{
        switch(self){
        case.Home:
            return "Home"
        case .Chats:
            return "Chats"
        case .Posts:
            return "Posts"
        case .Listings:
            return "Listings"
        case .Profile:
            return "Profile"
        }
    }
}

struct ContentView: View {
    @State private var tabSelection = page.Home
    @State private var title : [String] = ["Hauler","Discover", "Messages", "Posts", "Listings", "Profile"]
    @State var newChatId : String? = nil
    
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @EnvironmentObject var locationController : LocationManager
    @EnvironmentObject var pageController : ViewRouter
    @Binding var rootScreen :RootView
    
    var body: some View {
        TabView(selection: self.$tabSelection) {
            HomeView(rootScreen: $rootScreen)
                .environmentObject(pageController)
                .tabItem {
                    Image(systemName: "house")
                    Text(page.Home.name)
                }
                .tag(page.Home)
            
            ChatView(rootScreen: $rootScreen).tabItem {
                Image(systemName: "text.bubble")
                Text(page.Chats.name)
            }
            .tag(page.Chats)
            .badge(chatController.msgCount)
            
            PostView(rootScreen: $rootScreen).tabItem {
                Image(systemName: "camera")
                Text(page.Posts.name)
            }
            .tag(page.Posts)
            
            UserListingsView(rootScreen: $rootScreen).tabItem{
                Image(systemName: "list.bullet.rectangle.portrait")
                Text(page.Listings.name)
                
            }
            .tag(page.Listings)
            
            ProfileView(rootScreen: $rootScreen).tabItem{
                Image(systemName: "person")
                Text(page.Profile.name)
            }
            .tag(page.Profile)
        }
        .onReceive(pageController.objectWillChange, perform: {_ in
            switch(self.pageController.currentView){
            case .main:
                self.tabSelection = .Home
            case .chat:
                self.tabSelection = .Chats
            case .post:
                self.tabSelection = .Posts
            case .list:
                self.tabSelection = .Listings
            case .profile:
                self.tabSelection = .Profile
            }
            
        })
        //.navigationTitle($title[tabSelection])
//        .navigationTitle(((tabSelection == 1) ? $title[0] : $title[tabSelection]))
        
        .toolbar{
//            if(tabSelection == 1){
                ToolbarItem(placement:.navigationBarLeading){
//                    Text((tabSelection == .Home) ? title[0] : tabSelection.name)
//                        .font(.title)
//                        .bold()
                    Text(title[tabSelection.rawValue])
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                        //.padding(.vertical, 30)
                }
                
                ToolbarItem(placement:.navigationBarTrailing){
                    HStack{
                        NavigationLink(destination: FavoritesView()) {
                            Image(uiImage: UIImage(systemName: "heart.fill")!)
                                .resizable()
                                .frame(width: 15, height: 15)
                                .padding(15)
                                .clipShape(Circle())
                                .overlay(Circle().strokeBorder(Color(red: 220/255, green: 220/255, blue: 220/255), lineWidth: 1))
                            //.background(Color("HaulerOrange"), in:Circle())
                        }
                        Image(uiImage: UIImage(systemName: "bell")!)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(15)
                            .clipShape(Circle())
                            .overlay(Circle().strokeBorder(Color(red: 220/255, green: 220/255, blue: 220/255), lineWidth: 1))
                    }
                    //.padding(.vertical, 30)
                }
//            }
        }
//        .toolbarBackground(
//            .white,
//            for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear() {
            
        }
        .environmentObject(authController)
        .environmentObject(listingController)
        .environmentObject(imageController)
        .environmentObject(userProfileController)
        .environmentObject(chatController)
        .environmentObject(locationController)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
