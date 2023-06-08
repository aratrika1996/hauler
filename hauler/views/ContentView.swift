//
//  ContentView.swift
//  hauler
//
//  Created by Mahmoud Mraisi on 18/05/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var tabSelection = 1
    @State private var title : [String] = ["Hauler","Home", "Chats", "Posts", "Listings", "Profile"]
    @State var newChatId : String? = nil
    
    @EnvironmentObject var authController : AuthController
    @EnvironmentObject var listingController : ListingController
    @EnvironmentObject var imageController : ImageController
    @EnvironmentObject var userProfileController : UserProfileController
    @EnvironmentObject var chatController : ChatController
    @EnvironmentObject var pageController : ViewRouter
//    @StateObject private var viewRouter = ViewRouter()
    @Binding var rootScreen :RootView
    
    var body: some View {
        TabView(selection: self.$tabSelection) {
            HomeView()
            .environmentObject(pageController)
            .tabItem {
                Image(systemName: "house")
                Text(title[1])
            }
            .tag(1)
            
            ChatView(startNewChatWithId: newChatId,rootScreen: $rootScreen).tabItem {
                Image(systemName: "text.bubble")
                Text(title[2])
            }
            .tag(2)
            
            
            PostView().tabItem {
                Image(systemName: "camera")
                Text(title[3])
            }
            .tag(3)
            
            UserListingsView().tabItem{
                Image(systemName: "list.bullet.rectangle.portrait")
                Text(title[4])
                
            }
            .tag(4)
            
            ProfileView(rootScreen: $rootScreen).tabItem{
                Image(systemName: "person")
                Text(title[5])
            }
            .tag(5)
        }
        .onReceive(pageController.objectWillChange, perform: {_ in
            switch(self.pageController.currentView){
            case .main:
                self.tabSelection = 1
            case .chat:
                self.tabSelection = 2
            case .post:
                self.tabSelection = 3
            case .list:
                self.tabSelection = 4
            case .profile:
                self.tabSelection = 5
            }
            
        })
        .navigationTitle($title[tabSelection])
        .navigationTitle(((tabSelection == 1) ? $title[0] : $title[tabSelection]))
        
        .toolbar(content: {
            if(tabSelection == 1){
                ToolbarItem(content: {
                    HStack{
                        //                        Text(title[tabSelection])
                        Spacer()
                        Image(uiImage: UIImage(systemName: "heart.fill")!)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(15)
                            .background(Color("HaulerOrange"), in:Circle())
                        Image(uiImage: UIImage(systemName: "bell")!)
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(15)
                            .background(Color("HaulerOrange"), in:Circle())
                            .onTapGesture {
                                listingController.adminMode = !listingController.adminMode
                                listingController.removeAllListener()
                                listingController.getAllListings(adminMode: listingController.adminMode, completion: {_, err in if let err = err{print(err)}})
                            }
                    }
                    .padding(.horizontal, 10)
                })
            }
        })
        .onAppear() {
            UITabBar.appearance().backgroundColor = UIColor(named: "BackgroundGray") ?? .white
            
        }
        .environmentObject(authController)
        .environmentObject(listingController)
        .environmentObject(imageController)
        .environmentObject(userProfileController)
        .environmentObject(chatController)
        
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
